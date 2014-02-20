/**
 * VERSION: 12.0
 * DATE: 2012-01-12
 * AS2
 * UPDATES AND DOCS AT: http://www.greensock.com
 **/
import com.greensock.TweenLite;
import com.greensock.plugins.TweenPlugin;
/**
 * <p><strong>See AS3 files for full ASDocs</strong></p>
 * 
 * <p><strong>Copyright 2008-2014, GreenSock. All rights reserved.</strong> This work is subject to the terms in <a href="http://www.greensock.com/terms_of_use.html">http://www.greensock.com/terms_of_use.html</a> or for <a href="http://www.greensock.com/club/">Club GreenSock</a> members, the software agreement that was issued with the membership.</p>
 * 
 * @author Jack Doyle, jack@greensock.com
 */
class com.greensock.plugins.HexColorsPlugin extends TweenPlugin {
		public static var API:Number = 2; //If the API/Framework for plugins changes in the future, this number helps determine compatibility
		private var _colors:Array;
		
		public function HexColorsPlugin() {
			super("hexColors");
			_overwriteProps = [];
			_colors = [];
		}
		
		public function _onInitTween(target:Object, value:Object, tween:TweenLite):Boolean {
			for (var p:String in value) {
				_initColor(target, p, Number(value[p]));
			}
			return true;
		}
		
		public function _initColor(target:Object, p:String, end:Number):Void {
			var isFunc:Boolean = (typeof(target[p]) == "function"),
				start:Number = (!isFunc) ? target[p] : target[ ((p.indexOf("set") || typeof(target["get" + p.substr(3)]) !== "function") ? p : "get" + p.substr(3)) ]();
			if (start != end) {
				var r:Number = start >> 16,
					g:Number = (start >> 8) & 0xff,
					b:Number = start & 0xff;
				_colors[_colors.length] = {t:target, 
										   p:p, 
										   f:isFunc,
										   rs:r,
										   rc:(end >> 16) - r,
										   gs:g,
										   gc:((end >> 8) & 0xff) - g,
										   bs:b,
										   bc:(end & 0xff) - b};
				_overwriteProps[_overwriteProps.length] = p;
			}
		}
		
		public function _kill(lookup:Object):Boolean {
			var i:Number = _colors.length;
			while (--i > -1) {
				if (lookup[_colors[i].p] != null) {
					_colors.splice(i, 1);
				}
			}
			return super._kill(lookup);
		}	
		
		public function setRatio(v:Number):Void {
			var i:Number = _colors.length, clr:Object, val:Number;
			while (--i > -1) {
				clr = _colors[i];
				val = (clr.rs + (v * clr.rc)) << 16 | (clr.gs + (v * clr.gc)) << 8 | (clr.bs + (v * clr.bc));
				if (clr.f) {
					clr.t[clr.p](val);
				} else {
					clr.t[clr.p] = val;
				}
			}
		}
	
}