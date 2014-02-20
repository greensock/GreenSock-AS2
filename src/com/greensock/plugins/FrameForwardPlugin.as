/**
 * VERSION: 12.0.2
 * DATE: 2013-04-09
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
class com.greensock.plugins.FrameForwardPlugin extends TweenPlugin {
		public static var API:Number = 2; //If the API/Framework for plugins changes in the future, this number helps determine compatibility
		private var _start:Number;
		private var _change:Number;
		private var _max:Number;
		private var _target:MovieClip;
		private var _backward:Boolean;
		
		public function FrameForwardPlugin() {
			super("frameForward,frame,frameBackward,frameLabel");
		}
		
		public function _onInitTween(target:Object, value:Object, tween:TweenLite):Boolean {
			_target = MovieClip(target);
			_start = _target._currentframe;
			_max = _target._totalframes;
			_change = (typeof(value) === "number") ? Number(value) - _start : (typeof(value) === "string" && value.charAt(1) === "=") ? Number(value.charAt(0) + "1") * Number(value.substr(2)) : Number(value) || 0;
			if (!_backward && _change < 0) {
				_change = ((_change + (_max * 99999)) % _max) + ((_change / _max) | 0) * _max;
			} else if (_backward && _change > 0) {
				_change = ((_change - (_max * 99999)) % _max) - ((_change / _max) | 0) * _max;
			}
			return true;
		}
		
		public function setRatio(v:Number):Void {
			var frame:Number = (_change * v + _start) % _max;
			if (frame < 0.5 && frame >= -0.5) {
				frame = _max;
			} else if (frame < 0) {
				frame += _max;
			}
			frame = (frame + 0.5) | 0;
			if (frame != _target._currentframe) {
				_target.gotoAndStop( (frame + 0.5) >> 0 );
			}
		}
		
}