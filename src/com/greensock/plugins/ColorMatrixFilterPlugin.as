/**
 * VERSION: 12.0
 * DATE: 2012-01-12
 * AS2
 * UPDATES AND DOCS AT: http://www.greensock.com
 **/
import flash.filters.ColorMatrixFilter;
import com.greensock.TweenLite;
import com.greensock.plugins.FilterPlugin;
import com.greensock.plugins.EndArrayPlugin;
/**
 * <p><strong>See AS3 files for full ASDocs</strong></p>
 * 
 * <p><strong>Copyright 2008-2014, GreenSock. All rights reserved.</strong> This work is subject to the terms in <a href="http://www.greensock.com/terms_of_use.html">http://www.greensock.com/terms_of_use.html</a> or for <a href="http://www.greensock.com/club/">Club GreenSock</a> members, the software agreement that was issued with the membership.</p>
 * 
 * @author Jack Doyle, jack@greensock.com
 */
class com.greensock.plugins.ColorMatrixFilterPlugin extends FilterPlugin {
		public static var API:Number = 2; //If the API/Framework for plugins changes in the future, this number helps determine compatibility
		private static var _propNames:Array = [];
		private static var _idMatrix:Array = [1,0,0,0,0,0,1,0,0,0,0,0,1,0,0,0,0,0,1,0];
		private static var _lumR:Number = 0.212671; //Red constant
		private static var _lumG:Number = 0.715160; //Green constant
		private static var _lumB:Number = 0.072169; //Blue constant
		private var _matrix:Array;
		private var _matrixTween:EndArrayPlugin;
		
		public function ColorMatrixFilterPlugin() {
			super("colorMatrixFilter");
		}
		
		public function _onInitTween(target:Object, value:Object, tween:TweenLite):Boolean {
			var cmf:Object = value;
			_initFilter(target, {remove:value.remove, index:value.index, addFilter:value.addFilter}, tween, ColorMatrixFilter, new ColorMatrixFilter(_idMatrix.slice()), _propNames);
			_matrix = ColorMatrixFilter(_filter).matrix;
			var endMatrix:Array = [];
			if (cmf.matrix != null && (cmf.matrix instanceof Array)) {
				endMatrix = cmf.matrix;
			} else {
				if (cmf.relative) {
					endMatrix = _matrix.slice();
				} else {
					endMatrix = _idMatrix.slice();
				}
				endMatrix = setBrightness(endMatrix, cmf.brightness);
				endMatrix = setContrast(endMatrix, cmf.contrast);
				endMatrix = setHue(endMatrix, cmf.hue);
				endMatrix = setSaturation(endMatrix, cmf.saturation);
				endMatrix = setThreshold(endMatrix, cmf.threshold);
				if (!isNaN(cmf.colorize)) {
					endMatrix = colorize(endMatrix, cmf.colorize, cmf.amount);
				}
			}
			_matrixTween = new EndArrayPlugin();
			_matrixTween._init(_matrix, endMatrix);
			return true;
		}
		
		public function setRatio(v:Number):Void {
			_matrixTween.setRatio(v);
			ColorMatrixFilter(_filter).matrix = _matrix;
			super.setRatio(v);
		}
		
		
//---- MATRIX OPERATIONS --------------------------------------------------------------------------------
		
		public static function colorize(m:Array, color:Number, amount:Number):Array {
			if (isNaN(color)) {
				return m;
			} else if (isNaN(amount)) {
				amount = 1;
			}
			var r:Number = ((color >> 16) & 0xff) / 255,
				g:Number = ((color >> 8)  & 0xff) / 255,
				b:Number = (color         & 0xff) / 255,
				inv:Number = 1 - amount,
				temp:Array =  [inv + amount * r * _lumR, amount * r * _lumG,       amount * r * _lumB,       0, 0,
							  amount * g * _lumR,        inv + amount * g * _lumG, amount * g * _lumB,       0, 0,
							  amount * b * _lumR,        amount * b * _lumG,       inv + amount * b * _lumB, 0, 0,
							  0, 				          0, 					     0, 					    1, 0];		
			return applyMatrix(temp, m);
		}
		
		public static function setThreshold(m:Array, n:Number):Array {
			if (isNaN(n)) {
				return m;
			}
			var temp:Array = [_lumR * 256, _lumG * 256, _lumB * 256, 0,  -256 * n, 
						_lumR * 256, _lumG * 256, _lumB * 256, 0,  -256 * n, 
						_lumR * 256, _lumG * 256, _lumB * 256, 0,  -256 * n, 
						0,           0,           0,           1,  0]; 
			return applyMatrix(temp, m);
		}
		
		public static function setHue(m:Array, n:Number):Array {
			if (isNaN(n)) {
				return m;
			}
			n *= Math.PI / 180;
			var c:Number = Math.cos(n),
				s:Number = Math.sin(n),
				temp:Array = [(_lumR + (c * (1 - _lumR))) + (s * (-_lumR)), (_lumG + (c * (-_lumG))) + (s * (-_lumG)), (_lumB + (c * (-_lumB))) + (s * (1 - _lumB)), 0, 0, (_lumR + (c * (-_lumR))) + (s * 0.143), (_lumG + (c * (1 - _lumG))) + (s * 0.14), (_lumB + (c * (-_lumB))) + (s * -0.283), 0, 0, (_lumR + (c * (-_lumR))) + (s * (-(1 - _lumR))), (_lumG + (c * (-_lumG))) + (s * _lumG), (_lumB + (c * (1 - _lumB))) + (s * _lumB), 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1];
			return applyMatrix(temp, m);
		}
		
		public static function setBrightness(m:Array, n:Number):Array {
			if (isNaN(n)) {
				return m;
			}
			n = (n * 100) - 100;
			return applyMatrix([1,0,0,0,n,
								0,1,0,0,n,
								0,0,1,0,n,
								0,0,0,1,0,
								0,0,0,0,1], m);
		}
		
		public static function setSaturation(m:Array, n:Number):Array {
			if (isNaN(n)) {
				return m;
			}
			var inv:Number = 1 - n,
				r:Number = inv * _lumR,
				g:Number = inv * _lumG,
				b:Number = inv * _lumB,
				temp:Array = [r + n, g     , b     , 0, 0,
							  r     , g + n, b     , 0, 0,
							  r     , g     , b + n, 0, 0,
							  0     , 0     , 0     , 1, 0];
			return applyMatrix(temp, m);
		}
		
		public static function setContrast(m:Array, n:Number):Array {
			if (isNaN(n)) {
				return m;
			}
			n += 0.01;
			var temp:Array =  [n,0,0,0,128 * (1 - n),
							   0,n,0,0,128 * (1 - n),
							   0,0,n,0,128 * (1 - n),
							   0,0,0,1,0];
			return applyMatrix(temp, m);
		}
		
		public static function applyMatrix(m:Array, m2:Array):Array {
			if (!(m instanceof Array) || !(m2 instanceof Array)) {
				return m2;
			}
			var temp:Array = [], i:Number = 0, z:Number = 0, y:Number, x:Number;
			for (y = 0; y < 4; y++) {
				for (x = 0; x < 5; x++) {
					z = (x == 4) ? m[i + 4] : 0;
					temp[i + x] = m[i]   * m2[x]      + 
								  m[i+1] * m2[x + 5]  + 
								  m[i+2] * m2[x + 10] + 
								  m[i+3] * m2[x + 15] +
								  z;
				}
				i += 5;
			}
			return temp;
		}
	
}