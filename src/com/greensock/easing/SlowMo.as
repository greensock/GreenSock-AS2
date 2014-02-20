/**
 * VERSION: 1.11
 * DATE: 2012-06-06
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
class com.greensock.easing.SlowMo extends Ease {
		public static var ease:SlowMo = new SlowMo();
		private var _p:Number;
		
		public function SlowMo(linearRatio:Number, power:Number, yoyoMode:Boolean) {
			power = (power || power == 0) ? power : 0.7;
			if (linearRatio == undefined) {
				linearRatio = 0.7;
			} else if (linearRatio > 1) {
				linearRatio = 1;
			}
			_p = (linearRatio != 1) ? power : 0;
			_p1 = (1 - linearRatio) / 2;
			_p2 = linearRatio;
			_p3 = _p1 + _p2;
			_calcEnd = (yoyoMode == true);
		}
		
		public function getRatio(p:Number):Number {
			var r:Number = p + (0.5 - p) * _p;
			if (p < _p1) {
				return _calcEnd ? 1 - ((p = 1 - (p / _p1)) * p) : r - ((p = 1 - (p / _p1)) * p * p * p * r);
			} else if (p > _p3) {
				return _calcEnd ? 1 - (p = (p - _p3) / _p1) * p : r + ((p - r) * (p = (p - _p3) / _p1) * p * p * p);
			}
			return _calcEnd ? 1 : r;
		}
		
		public function config(linearRatio:Number, power:Number, yoyoMode:Boolean):SlowMo {
			return new SlowMo(linearRatio, power, yoyoMode);
		}
	
	
}
