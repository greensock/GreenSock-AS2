/**
 * VERSION: 12.0.14
 * DATE: 2013-07-27
 * AS2
 * UPDATES AND DOCS AT: http://www.greensock.com
 **/
import com.greensock.TweenLite;
import com.greensock.plugins.RoundPropsPlugin;
/**
 * TweenPlugin is the base class for all TweenLite/TweenMax plugins.
 * 	
 * 
 * <p><strong>See AS3 files for full ASDocs</strong></p>
 * 
 * <p><strong>Copyright 2008-2014, GreenSock. All rights reserved.</strong> This work is subject to the terms in <a href="http://www.greensock.com/terms_of_use.html">http://www.greensock.com/terms_of_use.html</a> or for <a href="http://www.greensock.com/club/">Club GreenSock</a> members, the software agreement that was issued with the membership.</p>
 * 
 * @author Jack Doyle, jack@greensock.com
 */
class com.greensock.plugins.TweenPlugin {
		public static var version:String = "12.0.14";
		public static var API:Number = 2.0; //If the API/Framework for plugins changes in the future, this number helps determine compatibility
		public var _propName:String;
		public var _overwriteProps:Array;
		public var _priority:Number;
		private var _firstPT:Object;
		
		public function TweenPlugin(props:String, priority:Number) {
			_overwriteProps = props.split(",");
			_propName = _overwriteProps[0];
			_priority = priority || 0;
		}
		
		public function _onInitTween(target:Object, value:Object, tween:TweenLite):Boolean {
			return false;
		}
		
		private function _addTween(target:Object, propName:String, start:Number, end:Object, overwriteProp:String, round:Boolean):Object {
			var c:Number;
			if (end != null && (c = (typeof(end) == "number" || end.charAt(1) !== "=") ? Number(end) - start : Number(end.charAt(0)+"1") * Number(end.substr(2)))) {
				_firstPT = {_next:_firstPT, t:target, p:propName, s:start, c:c, f:(typeof(target[propName]) == "function"), n:overwriteProp || propName, r:round};
				if (_firstPT._next) {
					_firstPT._next._prev = _firstPT;
				}
				return _firstPT;
			}
			return null;
		}
		
		public function setRatio(v:Number):Void {
			var pt:Object = _firstPT, val:Number;
			while (pt) {
				val = pt.c * v + pt.s;
				if (pt.r) {
					val = (val + ((val > 0) ? 0.5 : -0.5)) | 0; //about 4x faster than Math.round()
				}
				if (pt.f) {
					pt.t[pt.p](val);
				} else {
					pt.t[pt.p] = val;
				}
				pt = pt._next;
			}
		}
		
		public function _kill(lookup:Object):Boolean {
			if (lookup[_propName] != null) {
				_overwriteProps = [];
			} else {
				var i:Number = _overwriteProps.length;
				while (--i > -1) {
					if (lookup[_overwriteProps[i]] != null) {
						_overwriteProps.splice(i, 1);
					}
				}
			}
			var pt:Object = _firstPT;
			while (pt) {
				if (lookup[pt.n] != null) {
					if (pt._next) {
						pt._next._prev = pt._prev;
					}
					if (pt._prev) {
						pt._prev._next = pt._next;
						pt._prev = null;
					} else if (_firstPT == pt) {
						_firstPT = pt._next;
					}
				}
				pt = pt._next;
			}
			return false;
		}
		
		public function _roundProps(lookup:Object, value:Boolean):Void {
			var pt:Object = _firstPT;
			while (pt) {
				if (lookup[_propName] || (pt.n != null && lookup[ pt.n.split(_propName + "_").join("") ])) { //some properties that are very plugin-specific add a prefix named after the _propName plus an underscore, so we need to ignore that extra stuff here.
					pt.r = value;
				}
				pt = pt._next;
			}
		}
		
		private static function _onTweenEvent(type:String, tween:TweenLite):Boolean {
			var pt:Object = tween._firstPT, changed:Boolean;
			if (type === "_onInitAllProps") {
				//sorts the PropTween linked list in order of priority because some plugins need to render earlier/later than others, like MotionBlurPlugin applies its effects after all x/y/alpha tweens have rendered on each frame.
				var pt2:Object, first:Object, last:Object, next:Object;
				while (pt) {
					next = pt._next;
					pt2 = first;
					while (pt2 && pt2.pr > pt.pr) {
						pt2 = pt2._next;
					}
					if ((pt._prev = pt2 ? pt2._prev : last)) {
						pt._prev._next = pt;
					} else {
						first = pt;
					}
					if ((pt._next = pt2)) {
						pt2._prev = pt;
					} else {
						last = pt;
					}
					pt = next;
				}
				pt = tween._firstPT = first;
			}
			while (pt) {
				if (pt.pg) if (typeof(pt.t[type]) === "function") if (pt.t[type]()) {
					changed = true;
				}
				pt = pt._next;
			}
			return changed;
		}
		
		public static function activate(plugins:Array):Boolean {
			TweenLite._onPluginEvent = TweenPlugin._onTweenEvent;
			var i:Number = plugins.length;
			while (--i > -1) {
				if (plugins[i].API == TweenPlugin.API) {
					TweenLite._plugins[(new plugins[i]())._propName] = plugins[i];
				}
			}
			return true;
		}
		
}