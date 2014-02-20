/**
 * VERSION: 12.0
 * DATE: 2012-03-29
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
class com.greensock.plugins.ScalePlugin extends TweenPlugin {
		public static var API:Number = 2;
  
		public function ScalePlugin() {
			super("scale,_xscale,_yscale,_width,_height");
		}
  
		public function _onInitTween(target:Object, value:Object, tween:TweenLite):Boolean {
			if (target._xscale == null) {
				return false;
			}
			_addTween(target, "_xscale", target._xscale, value, "_xscale");
			_addTween(target, "_yscale", target._yscale, value, "_yscale");
			return true;
		}
		
}