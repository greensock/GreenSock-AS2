/**
 * VERSION: 12.0
 * DATE: 2012-01-12
 * AS2
 * UPDATES AND DOCS AT: http://www.greensock.com
 **/
import com.greensock.TweenLite;
import com.greensock.plugins.BezierPlugin;

/**
 * <p><strong>See AS3 files for full ASDocs</strong></p>
 * 
 * <p><strong>Copyright 2008-2014, GreenSock. All rights reserved.</strong> This work is subject to the terms in <a href="http://www.greensock.com/terms_of_use.html">http://www.greensock.com/terms_of_use.html</a> or for <a href="http://www.greensock.com/club/">Club GreenSock</a> members, the software agreement that was issued with the membership.</p>
 * 
 * @author Jack Doyle, jack@greensock.com
 */
class com.greensock.plugins.BezierThroughPlugin extends BezierPlugin {
		public static var API:Number = 2; //If the API/Framework for plugins changes in the future, this number helps determine compatibility
		
		public function BezierThroughPlugin() {
			super();
			_propName = "bezierThrough";
		}
		
		public function _onInitTween(target:Object, value:Object, tween:TweenLite):Boolean {
			if (value instanceof Array) {
				value = {values:value};
			}
			value.type = "thru";
			return super._onInitTween(target, value, tween);
		}
	
}