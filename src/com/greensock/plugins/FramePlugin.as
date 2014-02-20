/**
 * VERSION: 12.01
 * DATE: 2012-06-25
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
class com.greensock.plugins.FramePlugin extends TweenPlugin {
		public static var API:Number = 2; //If the API/Framework for plugins changes in the future, this number helps determine compatibility
		public var frame:Number;
		private var _target:MovieClip;
		
		public function FramePlugin() {
			super("frame,frameLabel,frameForward,frameBackward");
		}
		
		public function _onInitTween(target:Object, value:Object, tween:TweenLite):Boolean {
			if (typeof(target) != "movieclip" || isNaN(value)) {
				return false;
			}
			_target = MovieClip(target);
			this.frame = _target._currentframe;
			_addTween(this, "frame", this.frame, value, "frame", true);
			return true;
		}
		
		public function setRatio(v:Number):Void {
			super.setRatio(v);
			if (this.frame != _target._currentframe) {
				_target.gotoAndStop(this.frame);
			}
		}
		
}