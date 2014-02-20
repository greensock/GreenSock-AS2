/**
 * VERSION: 12.0.1
 * DATE: 2013-12-26
 * AS2
 * UPDATES AND DOCS AT: http://www.greensock.com
 **/
import com.greensock.*;
import com.greensock.plugins.*;
/**
 * <p><strong>See AS3 files for full ASDocs</strong></p>
 * 
 * <p><strong>Copyright 2008-2014, GreenSock. All rights reserved.</strong> This work is subject to the terms in <a href="http://www.greensock.com/terms_of_use.html">http://www.greensock.com/terms_of_use.html</a> or for <a href="http://www.greensock.com/club/">Club GreenSock</a> members, the software agreement that was issued with the membership.</p>
 * 
 * @author Jack Doyle, jack@greensock.com
 */
class com.greensock.plugins.QuaternionsPlugin extends TweenPlugin {
		public static var API:Number = 2; //If the API/Framework for plugins changes in the future, this number helps determine compatibility
		private static var _RAD2DEG:Number = 180 / Math.PI; //precalculate for speed
		private var _target:Object;
		private var _quaternions:Array;
		
		public function QuaternionsPlugin() {
			super("quaternions");
			_overwriteProps.pop();
			_quaternions = [];
		}
		
		public function _onInitTween(target:Object, value:Object, tween:TweenLite):Boolean {
			if (value == null) {
				return false;
			}
			_target = target;
			for (var p:String in value) {
				_initQuaternion(value[p], p);
			}
			return true;	
		}
		
		public function _initQuaternion(end:Object, p:String):Void {
			var angle:Number, q1:Object, q2:Object, x1:Number, x2:Number, y1:Number, y2:Number, z1:Number, z2:Number, w1:Number, w2:Number, theta:Number;
			var isFunc:Boolean = (typeof(_target[p]) == "function");
			q1 = (!isFunc) ? _target[p] : _target[ ((p.indexOf("set") || typeof(_target["get" + p.substr(3)]) !== "function") ? p : "get" + p.substr(3)) ]();
			q2 = end;
			x1 = q1.x; x2 = q2.x;
			y1 = q1.y; y2 = q2.y;
			z1 = q1.z; z2 = q2.z;
			w1 = q1.w; w2 = q2.w;
			angle = x1 * x2 + y1 * y2 + z1 * z2 + w1 * w2;
			if (angle < 0) {
				x1 *= -1;
				y1 *= -1;
				z1 *= -1;
				w1 *= -1;
				angle *= -1;
			}
			if ((angle + 1) < 0.000001) {
				y2 = -y1;
				x2 = x1;
				w2 = -w1;
				z2 = z1;
			}
			theta = Math.acos(angle);
			_quaternions[_quaternions.length] = [q1, p, x1, x2, y1, y2, z1, z2, w1, w2, angle, theta, 1 / Math.sin(theta), isFunc];
			_overwriteProps[_overwriteProps.length] = p;
		}
		
		public function _kill(lookup:Object):Boolean {
			var i:Number = _quaternions.length;
			while (--i > -1) {
				if (lookup[_quaternions[i][1]] != null) {
					_quaternions.splice(i, 1);
				}
			}
			return super._kill(lookup);
		}	
		
		public function setRatio(v:Number):Void {
			var i:Number = _quaternions.length, q:Array, scale:Number, invScale:Number;
			while (--i > -1) {
				q = _quaternions[i];
				if ((q[10] + 1) > 0.000001) {
					 if ((1 - q[10]) >= 0.000001) {
						scale = Math.sin(q[11] * (1 - v)) * q[12];
						invScale = Math.sin(q[11] * v) * q[12];
					 } else {
						scale = 1 - v;
						invScale = v;
					 }
				} else {
					scale = Math.sin(Math.PI * (0.5 - v));
					invScale = Math.sin(Math.PI * v);
				}
				q[0].x = scale * q[2] + invScale * q[3];
				q[0].y = scale * q[4] + invScale * q[5];
				q[0].z = scale * q[6] + invScale * q[7];
				q[0].w = scale * q[8] + invScale * q[9];
				if (q[13]) {
					_target[q[1]](q[0]);
				} else {
					_target[q[1]] = q[0];
				}
			}
			/*
			Array access is faster (though less readable). Here is the key:
			0 - target
			1 = p
			2 = x1
			3 = x2
			4 = y1
			5 = y2
			6 = z1
			7 = z2
			8 = w1
			9 = w2
			10 = angle
			11 = theta
			12 = invTheta
			13 = isFunction
			*/
		}
	
}