/**
 * VERSION: 12.0.5
 * DATE: 2013-03-28
 * AS2 (AS3 is also available)
 * UPDATES AND DOCS AT: http://www.greensock.com/roughease/
 **/
import mx.utils.Delegate;
import com.greensock.easing.Ease;
import com.greensock.easing.core.EasePoint;
/**
 * See AS3 files for full ASDocs
 * 
 * <p><strong>Copyright 2008-2014, GreenSock. All rights reserved.</strong> This work is subject to the terms in <a href="http://www.greensock.com/terms_of_use.html">http://www.greensock.com/terms_of_use.html</a> or for <a href="http://www.greensock.com/club/">Club GreenSock</a> members, the software agreement that was issued with the membership.</p>
 * 
 * @author Jack Doyle, jack@greensock.com
 */
class com.greensock.easing.RoughEase extends Ease {
		private static var _temp:EasePoint = new EasePoint(1,1,null); //without creating an EasePoint first, a bug in Flash prevents the RoughEase.ease from instantiating properly because the EasePoint class hasn't been instantiated.
		public static var ease:RoughEase = new RoughEase();
		private static var _lookup:Object = {};
		private static var _count:Number;
		
		private var _name:String;
		private var _first:EasePoint;
		private var _prev:EasePoint;
		
		public function RoughEase(vars, points:Number, clamp:Boolean, template:Ease, taper:String, randomize:Boolean, name:String) {
			if (typeof(vars) !== "object" || vars == null) {
				vars = {strength:vars, points:points, clamp:clamp, template:template, taper:taper, randomize:randomize, name:name};
			}
			if (vars.name) {
				_name = vars.name;
				_lookup[vars.name] = this;
			} else {
				if (_count == null) {
					_count = 0;
				}
				_name = "roughEase" + (_count++);
			}
			var taper:String = vars.taper || "none",
				a:Array = [],
				cnt:Number = 0,
				points:Number = (vars.points || 20) | 0,
				i:Number = points,
				randomize:Boolean = (vars.randomize !== false),
				clamp:Boolean = (vars.clamp === true),
				template:Ease = (vars.template instanceof Ease) ? vars.template : null,
				strength:Number = (typeof(vars.strength) === "number") ? vars.strength * 0.4 : 0.4,
				x:Number, y:Number, bump:Number, invX:Number, obj:Object;
			while (--i > -1) {
				x = randomize ? Math.random() : (1 / points) * i;
				y = (template != null) ? template.getRatio(x) : x;
				if (taper === "none") {
					bump = strength;
				} else if (taper === "out") {
					invX = 1 - x;
					bump = invX * invX * strength;
				} else if (taper === "in") {
					bump = x * x * strength;
				} else if (x < 0.5) { 	//"both" (start)
					invX = x * 2;
					bump = invX * invX * 0.5 * strength;
				} else {				//"both" (end)
					invX = (1 - x) * 2;
					bump = invX * invX * 0.5 * strength;
				}
				if (randomize) {
					y += (Math.random() * bump) - (bump * 0.5);
				} else if (i % 2) {
					y += bump * 0.5;
				} else {
					y -= bump * 0.5;
				}
				if (clamp) {
					if (y > 1) {
						y = 1;
					} else if (y < 0) {
						y = 0;
					}
				}
				a[cnt++] = {x:x, y:y};
			}
			a.sortOn("x", Array.NUMERIC);
			
			_first = new EasePoint(1, 1, null);
			i = points;
			while (--i > -1) {
				obj = a[i];
				_first = new EasePoint(obj.x, obj.y, _first);
			}
			
			_first = _prev = new EasePoint(0, 0, (_first.time !== 0) ? _first : _first.next);
		}
		
		public static function create(strength:Number, points:Number, restrictMaxAndMin:Boolean, templateEase:Ease, taper:String, randomize:Boolean, name:String):Ease {
			return new RoughEase(strength, points, restrictMaxAndMin, templateEase, taper, randomize, name);
		}
		
		public static function byName(name:String):Function {
			return _lookup[name];
		}
		
		public function getRatio(p:Number):Number {
			var pnt:EasePoint = _prev;
			if (p > _prev.time) {
				while (pnt.next && p >= pnt.time) {
					pnt = pnt.next;
				}
				pnt = pnt.prev;
			} else {
				while (pnt.prev && p <= pnt.time) {
					pnt = pnt.prev;
				}
			}
			_prev = pnt;
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
		
		public function config(vars):RoughEase {
			return new RoughEase(vars);
		}
		
}