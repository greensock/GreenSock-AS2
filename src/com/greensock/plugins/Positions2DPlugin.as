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
 * <p><strong>Copyright 2008-2013, GreenSock. All rights reserved.</strong> This work is subject to the terms in <a href="http://www.greensock.com/terms_of_use.html">http://www.greensock.com/terms_of_use.html</a> or for <a href="http://www.greensock.com/club/">Club GreenSock</a> members, the software agreement that was issued with the membership.</p>
 * 
 * @author Jack Doyle, jack@greensock.com
 */
class com.greensock.plugins.Positions2DPlugin extends TweenPlugin {
		public static var API:Number = 2; //If the API/Framework for plugins changes in the future, this number helps determine compatibility
		private var _target:Object;
		private var _positions:Array;
		
		public function Positions2DPlugin() {
			super("positions2D,_x,_y");
		}
		
		public function _onInitTween(target:Object, value:Object, tween:TweenLite):Boolean {
			if (!(value instanceof Array)) {
				return false;
			}
			_target = target;
			var a = value; //to avoid data type errors
			_positions = a;
			return true;
		}	
		
		public function setRatio(v:Number):Void {
			if (v < 0) {
				v = 0;
			} else if (v >= 1) {
				v = 0.999999999;
			}
			var position:Object = _positions[ (_positions.length * v) >> 0 ];
			_target._x = position.x;
			_target._y = position.y;
		}
		
}