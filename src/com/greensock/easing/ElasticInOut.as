/**
 * VERSION: 1.1
 * DATE: 2012-07-27
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
class com.greensock.easing.ElasticInOut extends Ease {
		private static var _2PI:Number = Math.PI * 2;
		public static var ease:ElasticInOut = new ElasticInOut();
		
		public function ElasticInOut(amplitude:Number, period:Number) {
			_p1 = amplitude || 1;
			_p2 = period || 0.45;
			_p3 = _p2 / _2PI * (Math.asin(1 / _p1) || 0); 
		}
		
		public function getRatio(p:Number):Number {
			return ((p*=2) < 1) ? -.5 * (_p1 * Math.pow(2, 10 * (p -= 1)) * Math.sin( (p - _p3) * _2PI / _p2)) : _p1 * Math.pow(2, -10 *(p -= 1)) * Math.sin( (p - _p3) * _2PI / _p2 ) *.5 + 1;
		}
		
		public function config(amplitude:Number, period:Number):ElasticInOut {
			return new ElasticInOut(amplitude, period);
		}
	
	
}
