/**
 * VERSION: 1.0
 * DATE: 2012-05-24
 * AS2
 * UPDATES AND DOCS AT: http://www.greensock.com/
 **/
import com.greensock.easing.Ease;
/**
 * See AS3 files for full ASDocs
 * 
 * <p><strong>Copyright 2008-2014, GreenSock. All rights reserved.</strong> This work is subject to the terms in <a href="http://www.greensock.com/terms_of_use.html">http://www.greensock.com/terms_of_use.html</a> or for <a href="http://www.greensock.com/club/">Club GreenSock</a> members, the software agreement that was issued with the membership.</p>
 * 
 * @author Jack Doyle, jack@greensock.com
 */
class com.greensock.easing.SteppedEase extends Ease {
	private var _steps:Number;
	
	public function SteppedEase(steps:Number) {
		_p1 = 1 / steps;
		_steps = steps + 1;
	}
	
	public static function create(steps:Number):SteppedEase {
		return new SteppedEase(steps);
	}
	
	public function getRatio(p:Number):Number {
		if (p < 0) {
			p = 0;
		} else if (p >= 1) {
			p = 0.999999999;
		}
		return ((_steps * p) >> 0) * _p1;
	}
	
	public static function config(steps:Number):SteppedEase {
		return new SteppedEase(steps);
	}
	
	public function get steps():Number {
		return _steps - 1;
	}
		
}