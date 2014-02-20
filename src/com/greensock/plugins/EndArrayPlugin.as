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
class com.greensock.plugins.EndArrayPlugin extends TweenPlugin {
		public static var API:Number = 2; //If the API/Framework for plugins changes in the future, this number helps determine compatibility
		private var _a:Array;
		private var _info:Array;
		private var _round:Boolean;
		
		public function EndArrayPlugin() {
			super("endArray");
			_info = [];
		}
		
		public function _onInitTween(target:Object, value:Object, tween:TweenLite):Boolean {
			if (!(target instanceof Array) || !(value instanceof Array)) {
				return false;
			}
			_init(Array(target), Array(value)); 
			return true;
		}
		
		public function _init(start:Array, end:Array):Void {
			_a = start;
			var i:Number = end.length, cnt:Number = 0;
			while (--i > -1) {
				if (start[i] != end[i] && start[i] != null) {
					_info[cnt++] = {i:i, s:_a[i], c:end[i] - _a[i]};
				}
			}
		}
		
		public function _roundProps(lookup:Object, value:Boolean):Void {
			if (lookup.endArray) {
				_round = value;
			}
		}
		
		public function setRatio(v:Number):Void {
			var i:Number = _info.length, ti:Object, val:Number;
			if (_round) {
				while (--i > -1) {
					ti = _info[i];
					_a[ti.i] = ((val = ti.c * v + ti.s) > 0) ? (val + 0.5) >> 0 : (val - 0.5) >> 0;
				}
			} else {
				while (--i > -1) {
					ti = _info[i];
					_a[ti.i] = ti.c * v + ti.s;
				}
			}
		}
	
}
