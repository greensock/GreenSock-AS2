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
class com.greensock.plugins.VolumePlugin extends TweenPlugin {
		public static var API:Number = 2; //If the API/Framework for plugins changes in the future, this number helps determine compatibility
		public var volume:Number;
		private var _sound:Sound;
		
		public function VolumePlugin() {
			super("volume");
		}
		
		public function _onInitTween(target:Object, value:Object, tween:TweenLite):Boolean {
			if (isNaN(value) || (typeof(target) != "movieclip" && !(target instanceof Sound))) {
				return false;
			}
			_sound = (typeof(target) == "movieclip") ? new Sound(target) : Sound(target);
			this.volume = _sound.getVolume();
			_addTween(this, "volume", this.volume, value, "volume");
			return true;
		}
		
		public function setRatio(v:Number):Void {
			super.setRatio(v);
			_sound.setVolume(this.volume);
		}
	
}