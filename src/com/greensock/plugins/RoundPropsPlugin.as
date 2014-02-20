/**
 * VERSION: 12.0
 * DATE: 2012-01-12
 * AS2
 * UPDATES AND DOCS AT: http://www.greensock.com
 **/
import com.greensock.*;
import com.greensock.plugins.*;
/**
 * <p><strong>See AS3 files for full ASDocs</strong></p>
 * 
 * <p><strong>Copyright 2008-2014, GreenSock. All rights reserved.</strong> This work is subject to the terms in <a href="http://www.greensock.com/terms_of_use.html">http://www.greensock.com/terms_of_use.html</a> or for <a href="http://www.greensock.com/club/">Club GreenSock</a> members, the software agreement that was issued with the membership.</p>
 * 
 * @author Jack Doyle, jack@greensock.com
 */
class com.greensock.plugins.RoundPropsPlugin extends TweenPlugin {
		public static var API:Number = 2; //If the API/Framework for plugins changes in the future, this number helps determine compatibility
		private var _tween:TweenLite;
		
		public function RoundPropsPlugin() {
			super("roundProps", -1);
		}
		
		public function _onInitTween(target:Object, value:Object, tween:TweenLite):Boolean {
			_tween = tween;
			return true;
		}
		
		public function _onInitAllProps():Boolean {
			var rp:Array = (_tween.vars.roundProps instanceof Array) ? _tween.vars.roundProps : _tween.vars.roundProps.split(","), 
				i:Number = rp.length,
				lookup:Object = {},
				rpt:Object = _tween._propLookup.roundProps,
				prop:String, pt:Object, next:Object;
			while (--i > -1) {
				lookup[rp[i]] = 1;
			}
			i = rp.length;
			while (--i > -1) {
				prop = rp[i];
				pt = _tween._firstPT;
				while (pt) {
					next = pt._next; //record here, because it may get removed
					if (pt.pg) {
						pt.t._roundProps(lookup, true);
					} else if (pt.n == prop) {
						_add(pt.t, prop, pt.s, pt.c);
						//remove from linked list
						if (next) {
							next._prev = pt._prev;
						}
						if (pt._prev) {
							pt._prev._next = next;
						} else if (_tween._firstPT == pt) {
							_tween._firstPT = next;
						}
						pt._next = pt._prev = null;
						_tween._propLookup[prop] = rpt;
					}
					pt = next;
				}
			}
			return false;
		}
				
		public function _add(target:Object, p:String, s:Number, c:Number):Void {
			_addTween(target, p, s, s + c, p, true);
			_overwriteProps[_overwriteProps.length] = p;
		}
	
}