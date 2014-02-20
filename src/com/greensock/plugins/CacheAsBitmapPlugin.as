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
class com.greensock.plugins.CacheAsBitmapPlugin extends TweenPlugin {
		public static var API:Number = 2; //If the API/Framework for plugins changes in the future, this number helps determine compatibility
		private var _target:MovieClip;
		private var _tween:TweenLite;
		private var _cacheAsBitmap:Boolean;
		private var _initVal:Boolean;
		
		public function CacheAsBitmapPlugin() {
			super("cacheAsBitmap");
		}
		
		public function _onInitTween(target:Object, value:Object, tween:TweenLite):Boolean {
			_target = MovieClip(target);
			_tween = tween;
			_initVal = _target.cacheAsBitmap;
			_cacheAsBitmap = Boolean(value);
			return true;
		}
		
		public function setRatio(v:Number):Void {
			if ((v == 1 && _tween._duration == _tween._time) || (v == 0 && _tween._time == 0)) { //a changeFactor of 1 doesn't necessarily mean the tween is done - if the ease is Elastic.easeOut or Back.easeOut for example, they could hit 1 mid-tween. 
				_target.cacheAsBitmap = _initVal;
			} else if (_target.cacheAsBitmap != _cacheAsBitmap) {
				_target.cacheAsBitmap = _cacheAsBitmap;
			}
		}

}