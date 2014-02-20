/**
 * VERSION: 12.0.1
 * DATE: 2013-02-09
 * AS2
 * UPDATES AND DOCS AT: http://www.greensock.com
 **/
import com.greensock.TweenLite;
import com.greensock.plugins.TweenPlugin;

import flash.display.*;
import flash.geom.*;
/**
 * <p><strong>See AS3 files for full ASDocs</strong></p>
 * 
 * <p><strong>Copyright 2008-2014, GreenSock. All rights reserved.</strong> This work is subject to the terms in <a href="http://www.greensock.com/terms_of_use.html">http://www.greensock.com/terms_of_use.html</a> or for <a href="http://www.greensock.com/club/">Club GreenSock</a> members, the software agreement that was issued with the membership.</p>
 * 
 * @author Jack Doyle, jack@greensock.com
 */
class com.greensock.plugins.TransformMatrixPlugin extends TweenPlugin {
		public static var API:Number = 2; //If the API/Framework for plugins changes in the future, this number helps determine compatibility
		private static var _DEG2RAD:Number = Math.PI / 180;
		private var _transform:Transform;
		private var _matrix:Matrix;
		private var _txStart:Number;
		private var _txChange:Number;
		private var _tyStart:Number;
		private var _tyChange:Number;
		private var _aStart:Number;
		private var _aChange:Number;
		private var _bStart:Number;
		private var _bChange:Number;
		private var _cStart:Number;
		private var _cChange:Number;
		private var _dStart:Number;
		private var _dChange:Number;
		private var _angleChange:Number;
		
		public function TransformMatrixPlugin() {
			super("transformMatrix,_x,_y,_xscale,_yscale,_rotation,shortRotation,transformAroundPoint,transformAroundCenter");
		}
		
		public function _onInitTween(target:Object, value:Object, tween:TweenLite):Boolean {
			_transform = target.transform;
			_matrix = _transform.matrix;
			var matrix:Matrix = _matrix.clone();
			_txStart = matrix.tx;
			_tyStart = matrix.ty;
			_aStart = matrix.a;
			_bStart = matrix.b;
			_cStart = matrix.c;
			_dStart = matrix.d;
			
			if (value._x != null) {
				_txChange = (typeof(value._x) == "number") ? value._x - _txStart : Number(value._x.split("=").join(""));
			} else if (value.tx != null) {
				_txChange = value.tx - _txStart;
			} else {
				_txChange = 0;
			}
			if (value._y != null) {
				_tyChange = (typeof(value._y) == "number") ? value._y - _tyStart : Number(value._y.split("=").join(""));
			} else if (value.ty != null) {
				_tyChange = value.ty - _tyStart;
			} else {
				_tyChange = 0;
			}
			
			_aChange = (value.a != null) ? value.a - _aStart : 0;
			_bChange = (value.b != null) ? value.b - _bStart : 0;
			_cChange = (value.c != null) ? value.c - _cStart : 0;
			_dChange = (value.d != null) ? value.d - _dStart : 0;
			_angleChange = 0;
			
			if ((value._rotation != null) || (value.shortRotation != null) || (value.scale != null && !(value instanceof Matrix)) || (value._xscale != null) || (value._yscale != null) || (value.skewX != null) || (value.skewY != null) || (value.skewX2 != null) || (value.skewY2 != null)) {
				var ratioX:Number, ratioY:Number;
				var scaleX:Number = Math.sqrt(matrix.a * matrix.a + matrix.b * matrix.b); //Bugs in the Flex framework prevent DisplayObject.scaleX from working consistently, so we must determine it using the matrix.
				if (scaleX == 0) {
					matrix.a = scaleX = 0.0001
				} else if (matrix.a < 0 && matrix.d > 0) {
					scaleX = -scaleX;
				}
				var scaleY:Number = Math.sqrt(matrix.c * matrix.c + matrix.d * matrix.d); //Bugs in the Flex framework prevent DisplayObject.scaleY from working consistently, so we must determine it using the matrix.
				if (scaleY == 0) {
					matrix.d = scaleY = 0.0001;
				} else if (matrix.d < 0 && matrix.a > 0) {
					scaleY = -scaleY;
				}
				var angle:Number = Math.atan2(matrix.b, matrix.a); //Bugs in the Flex framework prevent DisplayObject.rotation from working consistently, so we must determine it using the matrix
				if (matrix.a < 0 && matrix.d >= 0) {
					angle += (angle <= 0) ? Math.PI : -Math.PI;
				}
				var skewX:Number = Math.atan2(-_matrix.c, _matrix.d) - angle;
				
				var finalAngle:Number = angle;
				if (value.shortRotation != null) {
					var dif:Number = ((value.shortRotation * _DEG2RAD) - angle) % (Math.PI * 2);
					if (dif > Math.PI) {
						dif -= Math.PI * 2;
					} else if (dif < -Math.PI) {
						dif += Math.PI * 2;
					}
					finalAngle += dif;
				} else if (value._rotation != null) {
					finalAngle = (typeof(value._rotation) == "number") ? value._rotation * _DEG2RAD : Number(value._rotation.split("=").join("")) * _DEG2RAD + angle;
				}
				
				var finalSkewX:Number = (value.skewX != null) ? (typeof(value.skewX) == "number") ? Number(value.skewX) * _DEG2RAD : Number(value.skewX.split("=").join("")) * _DEG2RAD + skewX : 0;
				
				if (value.skewY != null) { //skewY is just a combonation of rotation and skewX
					var skewY:Number = (typeof(value.skewY) == "number") ? value.skewY * _DEG2RAD : Number(value.skewY.split("=").join("")) * _DEG2RAD - skewX;
					finalAngle += skewY + skewX;
					finalSkewX -= skewY;
				}
				
				if (finalAngle != angle) {
					if ((value._rotation != null) || (value.shortRotation != null)) {
						_angleChange = finalAngle - angle;
						finalAngle = angle; //to correctly affect the skewX calculations below
					} else {
						matrix.rotate(finalAngle - angle);
					}
				}
				
				if (value.scale != null) {
					ratioX = Number(value.scale) * 0.01 / scaleX;
					ratioY = Number(value.scale) * 0.01 / scaleY;
					if (typeof(value.scale) != "number") { //relative value
						ratioX += 1;
						ratioY += 1;
					}
				} else {
					if (value._xscale != null) {
						ratioX = Number(value._xscale) * 0.01 / scaleX;
						if (typeof(value._xscale) != "number") { //relative value
							ratioX += 1;
						}
					}
					if (value._yscale != null) {
						ratioY = Number(value._yscale) * 0.01 / scaleY;
						if (typeof(value._yscale) != "number") { //relative value
							ratioY += 1;
						}
					}
				}
				
				if (finalSkewX != skewX) {
					matrix.c = -scaleY * Math.sin(finalSkewX + finalAngle);
					matrix.d = scaleY * Math.cos(finalSkewX + finalAngle);
				}
				
				if (value.skewX2 != null) {
					if (typeof(value.skewX2) == "number") {
						matrix.c = Math.tan(0 - (value.skewX2 * _DEG2RAD));
					} else {
						matrix.c += Math.tan(0 - (Number(value.skewX2) * _DEG2RAD));
					}
				}
				if (value.skewY2 != null) {
					if (typeof(value.skewY2) == "number") {
						matrix.b = Math.tan(value.skewY2 * _DEG2RAD);
					} else {
						matrix.b += Math.tan(Number(value.skewY2) * _DEG2RAD);
					}
				}
				
				if (ratioX || ratioX == 0) { //faster than isNaN()
					matrix.a *= ratioX;
					matrix.b *= ratioX;
				}
				if (ratioY || ratioY == 0) {
					matrix.c *= ratioY;
					matrix.d *= ratioY;
				}
				_aChange = matrix.a - _aStart;
				_bChange = matrix.b - _bStart;
				_cChange = matrix.c - _cStart;
				_dChange = matrix.d - _dStart;
			}
			return true;
		}
		
		public function setRatio(v:Number):Void {
			_matrix.a = _aStart + (v * _aChange);
			_matrix.b = _bStart + (v * _bChange);
			_matrix.c = _cStart + (v * _cChange);
			_matrix.d = _dStart + (v * _dChange);
			if (_angleChange) {
				//about 3-4 times faster than _matrix.rotate(_angleChange * n);
				var cos:Number = Math.cos(_angleChange * v),
					sin:Number = Math.sin(_angleChange * v),
					a:Number = _matrix.a,
					c:Number = _matrix.c;
				_matrix.a = a * cos - _matrix.b * sin;
				_matrix.b = a * sin + _matrix.b * cos;
				_matrix.c = c * cos - _matrix.d * sin;
				_matrix.d = c * sin + _matrix.d * cos;
			}
			_matrix.tx = _txStart + (v * _txChange);
			_matrix.ty = _tyStart + (v * _tyChange);
			_transform.matrix = _matrix;
		}

}