/**
 * VERSION: 12.01
 * DATE: 2012-07-28
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
class com.greensock.plugins.TintPlugin extends TweenPlugin {
		public static var API:Number = 2; //If the API/Framework for plugins changes in the future, this number helps determine compatibility
		private var _color:Color;
		private var _ct:Object;
		
		public function TintPlugin() {
			super("tint,colorTransform,removeTint");
		}
		
		public function _onInitTween(target:Object, value:Object, tween:TweenLite):Boolean {
			if (typeof(target) != "movieclip" && !(target instanceof TextField)) {
				return false;
			}
			var alpha:Number = (tween.vars._alpha != undefined) ? tween.vars._alpha : (tween.vars.autoAlpha != null) ? tween.vars.autoAlpha : target._alpha;
			var n:Number = Number(value);
			var end:Object = (value == null || tween.vars.removeTint == true) ? {rb:0, gb:0, bb:0, ab:0, ra:alpha, ga:alpha, ba:alpha, aa:alpha} : {rb:(n >> 16), gb:(n >> 8) & 0xff, bb:(n & 0xff), ra:0, ga:0, ba:0, aa:alpha};
			_init(target, end);
			return true;
		}
		
		public function _init(target:Object, end:Object):Void {
			_color = new Color(target);
			var ct:Object = _color.getTransform();
			for (var p:String in end) {
				if (ct[p] != end[p]) {
					_addTween(ct, p, ct[p], end[p], "tint");
				}
			}
		}
		
		public function setRatio(v:Number):Void {
			var ct:Object = _color.getTransform(), //don't just use _ct because if alpha changes are made separately, they won't get applied properly.
				pt:Object = _firstPT;
			while (pt) {
				ct[pt.p] = pt.c * v + pt.s;
				pt = pt._next;
			}
			_color.setTransform(ct);
		}
	
}