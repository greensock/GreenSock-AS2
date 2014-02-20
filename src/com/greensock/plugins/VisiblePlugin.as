/**
 * VERSION: 12.1
 * DATE: 2012-06-19
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
class com.greensock.plugins.VisiblePlugin extends TweenPlugin {
		public static var API:Number = 2; //If the API/Framework for plugins changes in the future, this number helps determine compatibility
		private var _target:Object;
		private var _tween:TweenLite;
		private var _visible:Boolean;
		private var _initVal:Boolean;
		private var _progress:Number;
		
		public function VisiblePlugin() {
			super("_visible");
		}
		
		public function _onInitTween(target:Object, value:Object, tween:TweenLite):Boolean {
			_target = target;
			_tween = tween;
			_progress = (_tween.vars.runBackwards) ? 0 : 1;
			_initVal = _target._visible;
			_visible = Boolean(value);
			return true;
		}
		
		public function setRatio(v:Number):Void {
			_target._visible = (v == 1 && (_tween._time / _tween._duration == _progress || _tween._duration == 0)) ? _visible : _initVal; //a ratio of 1 doesn't necessarily mean the tween is done - if the ease is Elastic.easeOut or Back.easeOut, for example, it could it 1 mid-tween. Also remember that zero-duration tweens will return NaN for _time / _duration.
		}
	
}