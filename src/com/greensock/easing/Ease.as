/**
 * VERSION: 1.1
 * DATE: 2012-04-02
 * AS3 (AS2 and JS versions are also available)
 * UPDATES AND DOCS AT: http://www.greensock.com
 **/

/**
 * See AS3 files for full ASDocs
 * 
 * <p><strong>Copyright 2008-2014, GreenSock. All rights reserved.</strong> This work is subject to the terms in <a href="http://www.greensock.com/terms_of_use.html">http://www.greensock.com/terms_of_use.html</a> or for <a href="http://www.greensock.com/club/">Club GreenSock</a> members, the software agreement that was issued with the membership.</p>
 * 
 * @author Jack Doyle, jack@greensock.com
 */
class com.greensock.easing.Ease {
	
	private static var _baseParams:Array = [0, 0, 1, 1];
	private var _func:Function;
	private var _params:Array;
	private var _p1:Number;
	private var _p2:Number;
	private var _p3:Number;
	public var _type:Number;
	public var _power:Number;
	public var _calcEnd:Boolean;
	
	public function Ease(func:Function, extraParams:Array, type:Number, power:Number) {
		_func = func;
		_params = (extraParams) ? _baseParams.concat(extraParams) : _baseParams;
		_type = type || 0;
		_power = power || 0;
	}
	
	public function getRatio(p:Number):Number {
		if (_func) {
			_params[0] = p;
			return _func.apply(null, _params);
		} else {
			var r:Number = (_type === 1) ? 1 - p : (_type === 2) ? p : (p < 0.5) ? p * 2 : (1 - p) * 2;
			if (_power === 1) {
				r *= r;
			} else if (_power === 2) {
				r *= r * r;
			} else if (_power === 3) {
				r *= r * r * r;
			} else if (_power === 4) {
				r *= r * r * r * r;
			}
			return (_type === 1) ? 1 - r : (_type === 2) ? r : (p < 0.5) ? r / 2 : 1 - (r / 2);
		}
	}
	
}
