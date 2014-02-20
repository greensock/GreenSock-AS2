/**
 * VERSION: 12.0
 * DATE: 2012-01-12
 * AS2
 * UPDATES AND DOCS AT: http://www.greensock.com
 **/
import flash.geom.Rectangle;
import com.greensock.TweenLite;
import com.greensock.plugins.TweenPlugin;
/**
 * <p><strong>See AS3 files for full ASDocs</strong></p>
 * 
 * <p><strong>Copyright 2008-2014, GreenSock. All rights reserved.</strong> This work is subject to the terms in <a href="http://www.greensock.com/terms_of_use.html">http://www.greensock.com/terms_of_use.html</a> or for <a href="http://www.greensock.com/club/">Club GreenSock</a> members, the software agreement that was issued with the membership.</p>
 * 
 * @author Jack Doyle, jack@greensock.com
 */
class com.greensock.plugins.ScrollRectPlugin extends TweenPlugin {
		public static var API:Number = 2; //If the API/Framework for plugins changes in the future, this number helps determine compatibility
		private var _target:MovieClip;
		private var _rect:Rectangle;
		
		public function ScrollRectPlugin() {
			super("scrollRect");
		}
		
		public function _onInitTween(target:Object, value:Object, tween:TweenLite):Boolean {
			if (typeof(target) != "movieclip") {
				return false;
			}
			_target = MovieClip(target);
			if (_target.scrollRect != null) {
				_rect = Rectangle(_target.scrollRect);
			} else {
				var r:Object = _target.getBounds(_target);
				_rect = new Rectangle(0, 0, r.xMax, r.yMax);
			}
			for (var p:String in value) {
				_addTween(_rect, p, _rect[p], value[p], p);
			}
			return true;
		}
		
		public function setRatio(v:Number):Void {
			super.setRatio(v);
			_target.scrollRect = _rect;
		}

}