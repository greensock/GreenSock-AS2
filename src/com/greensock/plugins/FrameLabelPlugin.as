/**
 * VERSION: 12.0
 * DATE: 2012-01-12
 * AS2
 * UPDATES AND DOCS AT: http://www.greensock.com
 **/
import com.greensock.TweenLite;
import com.greensock.plugins.FramePlugin;
/**
 * <p><strong>See AS3 files for full ASDocs</strong></p>
 * 
 * <p><strong>Copyright 2008-2014, GreenSock. All rights reserved.</strong> This work is subject to the terms in <a href="http://www.greensock.com/terms_of_use.html">http://www.greensock.com/terms_of_use.html</a> or for <a href="http://www.greensock.com/club/">Club GreenSock</a> members, the software agreement that was issued with the membership.</p>
 * 
 * @author Jack Doyle, jack@greensock.com
 */
class com.greensock.plugins.FrameLabelPlugin extends FramePlugin {
		public static var API:Number = 2; //If the API/Framework for plugins changes in the future, this number helps determine compatibility
		
		public function FrameLabelPlugin() {
			super();
			_propName = "frameLabel";
		}
		
		public function _onInitTween(target:Object, value:Object, tween:TweenLite):Boolean {
			if (typeof(tween.target) != "movieclip") {
				return false;
			}
			
			_target = MovieClip(target);
			this.frame = _target._currentframe;
			var mc:MovieClip = _target.duplicateMovieClip("__frameLabelPluginTempMC", _target._parent.getNextHighestDepth()); //we don't want to gotAndStop() on the original MovieClip because it would interfere with playback if it's currently playing. We wouldn't know whether or not to gotoAndStop() or gotoAndPlay() back to the original frame afterwards. So we duplicate it and then remove the duplicate when we're done.
			mc.gotoAndStop(value);
			var endFrame:Number = mc._currentframe;
			mc.removeMovieClip();
			
			if (this.frame != endFrame) {
				_addTween(this, "frame", this.frame, endFrame, "frame", true);
			}
			return true;
		}
		
}