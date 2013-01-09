/**
 * VERSION: 0.8
 * DATE: 2012-05-20
 * AS2 (AS3 is also available)
 * UPDATES AND DOCS AT: http://www.greensock.com/roughease/
 **/
import mx.utils.Delegate;
import com.greensock.easing.Ease;
import com.greensock.easing.core.EasePoint;
/**
 * See AS3 files for full ASDocs
 * 
 * <p><strong>Copyright 2008-2013, GreenSock. All rights reserved.</strong> This work is subject to the terms in <a href="http://www.greensock.com/terms_of_use.html">http://www.greensock.com/terms_of_use.html</a> or for <a href="http://www.greensock.com/club/">Club GreenSock</a> members, the software agreement that was issued with the membership.</p>
 * 
 * @author Jack Doyle, jack@greensock.com
 */
class com.greensock.easing.RoughEase extends Ease {
		private static var _lookup:Object = {};
		private static var _count:Number;
		
		private var _name:String;
		private var _first:EasePoint;
		private var _last:EasePoint;
		
		public function RoughEase(strength:Number, points:Number, restrictMaxAndMin:Boolean, templateEase:Ease, taper:String, randomize:Boolean, name:String) {
			if (strength == undefined) {
				strength = 1;
			}
			if (points == undefined) {
				points = 20;
			}
			if (restrictMaxAndMin == undefined) {
				restrictMaxAndMin = false;
			}
			if (name == "") {
				if (_count == undefined) {
					_count = 0;
				}
				_name = "roughEase" + (_count++); 
			} else {
				_name = name;
				_lookup[_name] = this; 
			}
			if (taper == "" || taper == undefined) {
				taper = "none";
			}
			if (randomize == undefined) {
				randomize = true;
			}
			var a:Array = [];
			var cnt:Number = 0;
			var x:Number, y:Number, bump:Number, invX:Number, obj:Object;
			var i:Number = points;
			while (i--) {
				x = Math.random();
				y = (templateEase != undefined) ? templateEase.getRatio(x) : x;
				if (taper == "none") {
					bump = 0.4 * strength;
				} else if (taper == "out") {
					invX = 1 - x;
					bump = invX * invX * strength * 0.4;
				} else {
					bump = x * x * strength * 0.4;
				}
				if (randomize) {
					y += (Math.random() * bump) - (bump * 0.5);
				} else if (i % 2) {
					y += bump * 0.5;
				} else {
					y -= bump * 0.5;
				}
				if (restrictMaxAndMin) {
					if (y > 1) {
						y = 1;
					} else if (y < 0) {
						y = 0;
					}
				}
				a[cnt++] = {x:x, y:y};
			}
			a.sortOn("x", Array.NUMERIC);
			
			_first = _last = new EasePoint(1, 1, null);
			
			i = points;
			while (i--) {
				obj = a[i];
				_first = new EasePoint(obj.x, obj.y, _first);
			}
			_first = new EasePoint(0, 0, _first);
		}
		
		public static function create(strength:Number, points:Number, restrictMaxAndMin:Boolean, templateEase:Ease, taper:String, randomize:Boolean, name:String):Ease {
			return new RoughEase(strength, points, restrictMaxAndMin, templateEase, taper, randomize, name);
		}
		
		public static function byName(name:String):Function {
			return _lookup[name];
		}
		
		public function getRatio(p:Number):Number {
			var pnt:EasePoint;
			if (p < 0.5) {
				pnt = _first;
				while (pnt.time <= p) {
					pnt = pnt.next;
				}
				pnt = pnt.prev;
			} else {
				pnt = _last;
				while (pnt.time >= p) {
					pnt = pnt.prev;
				}
			}
			
			return (pnt.value + ((p - pnt.time) / pnt.gap) * pnt.change);
		}
		
		public function dispose():Void {
			delete _lookup[_name];
		}
		
		public function get name():String {
			return _name;
		}
		public function set name(value:String):Void {
			delete _lookup[_name];
			_name = value;
			_lookup[_name] = this;
		}
		
}