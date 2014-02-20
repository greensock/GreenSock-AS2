/**
 * VERSION: 12.0
 * DATE: 2012-02-14
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
class com.greensock.plugins.ShortRotationPlugin extends TweenPlugin {
		public static var API:Number = 2; //If the API/Framework for plugins changes in the future, this number helps determine compatibility
		
		public function ShortRotationPlugin() {
			super("shortRotation");
			_overwriteProps = [];
		}
		
		public function _onInitTween(target:Object, value:Object, tween:TweenLite):Boolean {
			if (typeof(value) == "number") {
				return false;
			}
			var useRadians:Boolean = Boolean(value.useRadians == true), start:Number; 
			for (var p:String in value) {
				if (p != "useRadians") {
					start = (typeof(target[p]) == "function") ? target[ ((p.indexOf("set") || typeof(target["get" + p.substr(3)]) !== "function") ? p : "get" + p.substr(3)) ]() : target[p];
					_initRotation(target, p, start, (typeof(value[p]) == "number") ? Number(value[p]) : start + Number(value[p].split("=").join("")), useRadians);
				}
			}
			return true;
		}
		
		public function _initRotation(target:Object, p:String, start:Number, end:Number, useRadians:Boolean):Void {
			var cap:Number = useRadians ? Math.PI * 2 : 360,
				dif:Number = (end - start) % cap;
			if (dif != dif % (cap / 2)) {
				dif = (dif < 0) ? dif + cap : dif - cap;
			}
			_addTween(target, p, start, start + dif, p);
			_overwriteProps[_overwriteProps.length] = p;
		}
	
}