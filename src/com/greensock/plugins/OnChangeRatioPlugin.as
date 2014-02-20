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
class com.greensock.plugins.OnChangeRatioPlugin extends TweenPlugin {
		public static var API:Number = 2; //If the API/Framework for plugins changes in the future, this number helps determine compatibility
		private var _func:Function;
		private var _tween:TweenLite;
		private var _ratio:Number;
		
		public function OnChangeRatioPlugin() {
			super("onChangeRatio");
			_ratio = 0;
		}
		
		public function _onInitTween(target:Object, value:Object, tween:TweenLite):Boolean {
			if (typeof(value) != "function") {
				return false;
			}
			_func = Function(value);
			_tween = tween;
			return true;
		}	
		
		public function setRatio(v:Number):Void {
			if (_ratio != v) {
				_func(_tween);
				_ratio = v;
			}
		}
	
}