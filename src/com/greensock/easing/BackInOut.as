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
class com.greensock.easing.BackInOut extends Ease {
		public static var ease:BackInOut = new BackInOut();

		public function BackInOut(overshoot:Number) {
			_p1 = (overshoot || overshoot == 0) ? overshoot : 1.70158;
			_p2 = _p1 * 1.525;
		}
		
		public function getRatio(p:Number):Number {
			return ((p*=2) < 1) ? 0.5 * p * p * ((_p2 + 1) * p - _p2) : 0.5 * ((p -= 2) * p * ((_p2 + 1) * p + _p2) + 2);
		}
		
		public function config(overshoot:Number):BackInOut {
			return new BackInOut(overshoot);
		}
	
}
