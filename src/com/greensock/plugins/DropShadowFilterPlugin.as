/**
 * VERSION: 12.0
 * DATE: 2013-03-25
 * AS2
 * UPDATES AND DOCS AT: http://www.greensock.com
 **/
import com.greensock.TweenLite;
import com.greensock.plugins.FilterPlugin;
import flash.filters.DropShadowFilter;	
/**
 * <p><strong>See AS3 files for full ASDocs</strong></p>
 * 
 * <p><strong>Copyright 2008-2014, GreenSock. All rights reserved.</strong> This work is subject to the terms in <a href="http://www.greensock.com/terms_of_use.html">http://www.greensock.com/terms_of_use.html</a> or for <a href="http://www.greensock.com/club/">Club GreenSock</a> members, the software agreement that was issued with the membership.</p>
 * 
 * @author Jack Doyle, jack@greensock.com
 */
class com.greensock.plugins.DropShadowFilterPlugin extends FilterPlugin {
		public static var API:Number = 2; //If the API/Framework for plugins changes in the future, this number helps determine compatibility
		private static var _propNames:Array = ["distance","angle","color","alpha","blurX","blurY","strength","quality","inner","knockout","hideObject"];
		
		public function DropShadowFilterPlugin() {
			super("dropShadowFilter");
		}
		
		public function _onInitTween(target:Object, value:Object, tween:TweenLite):Boolean {
			return _initFilter(target, value, tween, DropShadowFilter, new DropShadowFilter(0, 45, 0x000000, 0, 0, 0, 1, value.quality || 2, value.inner, value.knockout, value.hideObject), _propNames);
		}
	
}