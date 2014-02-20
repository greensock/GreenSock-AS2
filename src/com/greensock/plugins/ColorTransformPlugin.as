/**
 * VERSION: 12.0
 * DATE: 2012-01-12
 * AS2
 * UPDATES AND MORE DOCS AT: http://www.greensock.com
 **/
import com.greensock.TweenLite;
import com.greensock.plugins.TintPlugin;
/**
 * <p><strong>See AS3 files for full ASDocs</strong></p>
 * 
 * <p><strong>Copyright 2008-2014, GreenSock. All rights reserved.</strong> This work is subject to the terms in <a href="http://www.greensock.com/terms_of_use.html">http://www.greensock.com/terms_of_use.html</a> or for <a href="http://www.greensock.com/club/">Club GreenSock</a> members, the software agreement that was issued with the membership.</p>
 * 
 * @author Jack Doyle, jack@greensock.com
 */
class com.greensock.plugins.ColorTransformPlugin extends TintPlugin {
		public static var API:Number = 2; //If the API/Framework for plugins changes in the future, this number helps determine compatibility
		
		public function ColorTransformPlugin() {
			super();
			_propName = "colorTransform";
		}
		
		public function _onInitTween(target:Object, value:Object, tween:TweenLite):Boolean {
			if (typeof(target) != "movieclip" && !(target instanceof TextField)) {
				return false;
			}
			var color:Color = new Color(target);
			var end:Object = color.getTransform();
			
			if (value.redMultiplier != null) {
				end.ra = value.redMultiplier * 100;
			}
			if (value.greenMultiplier != null) {
				end.ga = value.greenMultiplier * 100;
			}
			if (value.blueMultiplier != null) {
				end.ba = value.blueMultiplier * 100;
			}
			if (value.alphaMultiplier != null) {
				end.aa = value.alphaMultiplier * 100;
			}
			if (value.redOffset != null) {
				end.rb = value.redOffset;
			}
			if (value.greenOffset != null) {
				end.gb = value.greenOffset;
			}
			if (value.blueOffset != null) {
				end.bb = value.blueOffset;
			}
			if (value.alphaOffset != null) {
				end.ab = value.alphaOffset;
			}
			if (!isNaN(value.tint) || !isNaN(value.color)) {
				var tint:Object = (!isNaN(value.tint)) ? value.tint : value.color; //make it an object so that it can be null (Numbers can't)
				if (tint != null) {
					/* to clear the ColorTransform (make it return to normal), use this...
					var alpha:Number = target._alpha;
					end.rb = 0;
					end.gb = 0;
					end.bb = 0;
					end.ra = alpha;
					end.ga = alpha;
					end.ba = alpha;
					end.aa = alpha;
					*/
					end.rb = (Number(tint) >> 16);
					end.gb = (Number(tint) >> 8) & 0xff;
					end.bb = (Number(tint) & 0xff);
					end.ra = 0;
					end.ga = 0;
					end.ba = 0;
				}
			}
			
			if (!isNaN(value.tintAmount)) {
				var ratio:Number = value.tintAmount / (1 - ((end.ra + end.ga + end.ba) / 300));
				end.rb *= ratio;
				end.gb *= ratio;
				end.bb *= ratio;
				end.ra = end.ga = end.ba = (1 - value.tintAmount) * 100;
			} else if (!isNaN(value.exposure)) {
				end.rb = end.gb = end.bb = 255 * (value.exposure - 1);
				end.ra = end.ga = end.ba = 100;
			} else if (!isNaN(value.brightness)) {
				end.rb = end.gb = end.bb = Math.max(0, (value.brightness - 1) * 255);
				end.ra = end.ga = end.ba = (1 - Math.abs(value.brightness - 1)) * 100;
			}
			
			if (tween.vars._alpha != null && value.alphaMultiplier == null) {
				end.aa = tween.vars._alpha;
				tween._kill({_alpha:1});
			}
			
			_init(target, end);
			return true;
		}
	
}