/**
 * VERSION: 1.0
 * DATE: 2012-03-22
 * AS3 (AS2 and JS versions are also available)
 * UPDATES AND DOCS AT: http://www.greensock.com
 **/
import com.greensock.easing.*;
/**
 * See AS3 files for full ASDocs
 * 
 * <p><strong>Copyright 2008-2014, GreenSock. All rights reserved.</strong> This work is subject to the terms in <a href="http://www.greensock.com/terms_of_use.html">http://www.greensock.com/terms_of_use.html</a> or for <a href="http://www.greensock.com/club/">Club GreenSock</a> members, the software agreement that was issued with the membership.</p>
 * 
 * @author Jack Doyle, jack@greensock.com
 */
class com.greensock.easing.EaseLookup {
		private static var _lookup:Object;
		
		public static function find(name:String):Ease {
			if (_lookup == undefined) {
				_lookup = {};
				
				_addInOut(Back, ["back"]);
				_addInOut(Bounce, ["bounce"]);
				_addInOut(Circ, ["circ", "circular"]);
				_addInOut(Cubic, ["cubic","power2"]);
				_addInOut(Elastic, ["elastic"]);
				_addInOut(Expo, ["expo", "exponential"]);
				_addInOut(Power0, ["linear","power0"]);
				_addInOut(Quad, ["quad", "quadratic","power1"]);
				_addInOut(Quart, ["quart","quartic","power3"]);
				_addInOut(Quint, ["quint", "quintic", "strong","power4"]);
				_addInOut(Sine, ["sine"]);
				
				_lookup["linear.easenone"] = _lookup["lineareasenone"] = Linear.easeNone;
				_lookup.slowmo = _lookup["slowmo.ease"] = SlowMo.ease;
				
			}
			return _lookup[name.toLowerCase()];
		}
		
		private static function _addInOut(easeClass:Function, names:Array):Void {
			var name:String, i:Number = names.length;
			while (i-- > 0) {
				name = names[i].toLowerCase();
				_lookup[name + ".easein"] = _lookup[name + "easein"] = easeClass.easeIn;
				_lookup[name + ".easeout"] = _lookup[name + "easeout"] = easeClass.easeOut;
				_lookup[name + ".easeinout"] = _lookup[name + "easeinout"] = easeClass.easeInOut;
			}
		}
	
}