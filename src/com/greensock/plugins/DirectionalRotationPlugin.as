/**
 * VERSION: 12.0.5
 * DATE: 2013-03-26
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
class com.greensock.plugins.DirectionalRotationPlugin extends TweenPlugin {
		public static var API:Number = 2; //If the API/Framework for plugins changes in the future, this number helps determine compatibility
		private var finals:Object;
		
		public function DirectionalRotationPlugin() {
			super("directionalRotation");
			_overwriteProps.pop();
		}
		
		public function _onInitTween(target:Object, value:Object, tween:TweenLite):Boolean {
			if (typeof(value) !== "object") {
				value = {_rotation:value};
			}
			finals = {};
			var cap:Number = (value.useRadians === true) ? Math.PI * 2 : 360,
				p:String, v:Object, start:Number, end:Number, dif:Number, split:Array, type:String;
			for (p in value) {
				if (p !== "useRadians") {
					split = (value[p] + "").split("_");
					v = split[0];
					type = split[1];
					start = parseFloat( (typeof(target[p]) !== "function") ? target[p] : target[ ((p.indexOf("set") || typeof(target["get" + p.substr(3)]) !== "function") ? p : "get" + p.substr(3)) ]() );
					end = finals[p] = (typeof(v) === "string" && v.charAt(1) === "=") ? start + parseInt(v.charAt(0) + "1", 10) * Number(v.substr(2)) : Number(v) || 0;
					dif = end - start;
					if (type === "short") {
						dif = dif % cap;
						if (dif !== dif % (cap / 2)) {
							dif = (dif < 0) ? dif + cap : dif - cap;
						}
					} else if (type === "cw" && dif < 0) {
						dif = ((dif + cap * 9999999999) % cap) - ((dif / cap) | 0) * cap;
					} else if (type === "ccw" && dif > 0) {
						dif = ((dif - cap * 9999999999) % cap) - ((dif / cap) | 0) * cap;
					}
					_addTween(target, p, start, start + dif, p);
					_overwriteProps.push(p);
				}
			}
			return true;
		}
		
		public function setRatio(v:Number):Void {
			var pt:Object;
			if (v !== 1) {
				super.setRatio(v);
			} else {
				pt = _firstPT;
				while (pt) {
					if (pt.f) {
						pt.t[pt.p](finals[pt.p]);
					} else {
						pt.t[pt.p] = finals[pt.p];
					}
					pt = pt._next;
				}
			}
		}
	
}