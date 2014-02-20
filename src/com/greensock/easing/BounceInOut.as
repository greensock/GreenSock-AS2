/**
 * VERSION: 1.0
 * DATE: 2012-03-22
 * AS3 (AS2 and JS versions are also available)
 * UPDATES AND DOCS AT: http://www.greensock.com
 **/
import com.greensock.easing.Ease;
/**
 * See AS3 files for full ASDocs
 * 
 * <p><strong>Copyright 2008-2014, GreenSock. All rights reserved.</strong> This work is subject to the terms in <a href="http://www.greensock.com/terms_of_use.html">http://www.greensock.com/terms_of_use.html</a> or for <a href="http://www.greensock.com/club/">Club GreenSock</a> members, the software agreement that was issued with the membership.</p>
 * 
 * @author Jack Doyle, jack@greensock.com
 */
class com.greensock.easing.BounceInOut extends Ease {
		public static var ease:BounceInOut = new BounceInOut();
		
		public function getRatio(p:Number):Number {
			var invert:Boolean = (p < 0.5);
			if (invert) {
				p = 1 - (p * 2);
			} else {
				p = (p * 2) - 1;
			}
			if (p < 1 / 2.75) {
				p = 7.5625 * p * p;
			} else if (p < 2 / 2.75) {
				p = 7.5625 * (p -= 1.5 / 2.75) * p + .75;
			} else if (p < 2.5 / 2.75) {
				p = 7.5625 * (p -= 2.25 / 2.75) * p + .9375;
			} else {
				p = 7.5625 * (p -= 2.625 / 2.75) * p + .984375;
			}
			return invert ? (1 - p) * 0.5 : p * 0.5 + 0.5;
		}
	
	
}
