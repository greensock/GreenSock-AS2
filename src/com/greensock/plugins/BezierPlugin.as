/**
 * VERSION: 12.14
 * DATE: 2014-03-12
 * AS2
 * UPDATES & DOCS AT: http://www.greensock.com
 **/
import com.greensock.TweenLite;
import com.greensock.plugins.TweenPlugin;
import com.greensock.plugins.core.Segment;
/**
 * <p><strong>See AS3 files for full ASDocs</strong></p>
 * 
 * <p><strong>Copyright 2008-2014, GreenSock. All rights reserved.</strong> This work is subject to the terms in <a href="http://www.greensock.com/terms_of_use.html">http://www.greensock.com/terms_of_use.html</a> or for <a href="http://www.greensock.com/club/">Club GreenSock</a> members, the software agreement that was issued with the membership.</p>
 * 
 * @author Jack Doyle, jack@greensock.com
 */
class com.greensock.plugins.BezierPlugin extends TweenPlugin {
		public static var API:Number = 2; //If the API/Framework for plugins changes in the future, this number helps determine compatibility
		private static var _RAD2DEG:Number = 180 / Math.PI; //precalculate for speed
		private static var _r1:Array = []; 
		private static var _r2:Array = []; 
		private static var _r3:Array = []; 
		private static var _corProps:Object = {};
		
		private var _target:Object;
		private var _autoRotate:Array;
		private var _round:Object;
		private var _lengths:Array;
		private var _segments:Array;
		private var _length:Number;
		private var _func:Object;
		private var _props:Array;
		private var _l1:Number; 
		private var _l2:Number; 
		private var _li:Number; 
		private var _curSeg:Array; 
		private var _s1:Number;
		private var _s2:Number; 
		private var _si:Number; 
		private var _beziers:Object;
		private var _segCount:Number;
		private var _prec:Number;
		private var _timeRes:Number;
		private var _initialRotations:Array;
		private var _startRatio:Number;
		
		
		public function BezierPlugin() {
			super("bezier");
			this._overwriteProps.pop();
			this._func = {};
			this._round = {};
		}
		
		public function _onInitTween(target:Object, value:Object, tween:TweenLite):Boolean {
			this._target = target;
			var vars:Object = (value instanceof Array) ? {values:value} : value;
			this._props = [];
			this._timeRes = (vars.timeResolution == null) ? 6 : (vars.timeResolution) >> 0;
			var values:Array = vars.values || [],
				first:Object = {},
				second:Object = values[0],
				autoRotate:Object = vars.autoRotate || tween.vars.orientToBezier,
				p:String, isFunc:Boolean, i:Number, j:Number, ar:Array, prepend:Object;
			
			this._autoRotate = autoRotate ? (autoRotate instanceof Array) ? [autoRotate][0] : [["_x","_y","_rotation",((autoRotate === true) ? 0 : Number(autoRotate))]] : null;
			
			for (p in second) {
				this._props.push(p);
			}
			
			i = this._props.length;
			while (--i > -1) {
				p = this._props[i];
				this._overwriteProps.push(p);
				isFunc = this._func[p] = (typeof(target[p]) === "function");
				first[p] = (!isFunc) ? target[p] : target[ ((p.indexOf("set") || typeof(target["get" + p.substr(3)]) !== "function") ? p : "get" + p.substr(3)) ]();
				if (!prepend) if (first[p] !== values[0][p]) {
					prepend = first;
				}
			}
			this._beziers = (vars.type !== "cubic" && vars.type !== "quadratic" && vars.type !== "soft") ? bezierThrough(values, isNaN(vars.curviness) ? 1 : vars.curviness, false, (vars.type === "thruBasic"), vars.correlate, prepend) : _parseBezierData(values, vars.type, first);
			this._segCount = this._beziers[p].length;
			
			if (this._timeRes) {
				var ld:Object = _parseLengthData(this._beziers, this._timeRes);
				this._length = ld.length;
				this._lengths = ld.lengths;
				this._segments = ld.segments;
				this._l1 = this._li = this._s1 = this._si = 0;
				this._l2 = this._lengths[0];
				this._curSeg = this._segments[0];
				this._s2 = this._curSeg[0];
				this._prec = 1 / this._curSeg.length;
			}
			
			if ((ar = this._autoRotate)) {
				this._initialRotations = [];
				if (!(ar[0] instanceof Array)) {
					this._autoRotate = ar = [ar];
				}
				i = ar.length;
				while (--i > -1) {
					for (j = 0; j < 3; j++) {
						p = ar[i][j];
						this._func[p] = (typeof(target[p]) === "function") ? target[ ((p.indexOf("set") || typeof(target["get" + p.substr(3)]) !== "function") ? p : "get" + p.substr(3)) ] : false;
					}
					p = ar[i][2];
					this._initialRotations[i] = this._func[p] ? this._func[p]() : this._target[p];
				}
			}
			this._startRatio = tween.vars.runBackwards ? 1 : 0;
			return true;
		}
		
		public static function bezierThrough(values:Array, curviness:Number, quadratic:Boolean, basic:Boolean, correlate:String, prepend:Object):Object {
			if (curviness == null) {
				curviness = 1;
			}
			var obj:Object = {},
				props:Array = [],
				first:Object = prepend || values[0],
				i:Number, p:String, j:Number, a:Array, l:Number, r:Number, seamless:Boolean, last:Object;
			correlate = (typeof(correlate) === "string") ? ","+correlate+"," : ",_x,_y,x,y,z,";
			for (p in values[0]) {
				props.push(p);
			}
			//check to see if the last and first values are identical (well, within 0.05). If so, make seamless by appending the second element to the very end of the values array and the 2nd-to-last element to the very beginning (we'll remove those segments later)
			if (values.length > 1) {
				last = values[values.length - 1];
				seamless = true;
				i = props.length;
				while (--i > -1) {
					p = props[i];
					if (Math.abs(first[p] - last[p]) > 0.05) { //build in a tolerance of +/-0.05 to accommodate rounding errors. For example, if you set an object's position to 4.945, Flash will make it 4.9
						seamless = false;
						break;
					}
				}
				if (seamless) {
					values = values.concat(); //duplicate the array to avoid contaminating the original which the user may be reusing for other tweens
					if (prepend) {
						values.unshift(prepend);
					}
					values.push(values[1]);
					prepend = values[values.length - 3];
				}
			}
			_r1.length = _r2.length = _r3.length = 0;
			i = props.length;
			while (--i > -1) {
				p = props[i];
				_corProps[p] = (correlate.indexOf(","+p+",") !== -1);
				obj[p] = _parseAnchors(values, p, _corProps[p], prepend);
			}
			i = _r1.length;
			while (--i > -1) {
				_r1[i] = Math.sqrt(_r1[i]);
				_r2[i] = Math.sqrt(_r2[i]);
			}
			if (!basic) {
				i = props.length;
				while (--i > -1) {
					if (_corProps[p]) {
						a = obj[props[i]];
						l = a.length - 1;
						for (j = 0; j < l; j++) {
							r = a[j+1].da / _r2[j] + a[j].da / _r1[j]; 
							_r3[j] = (_r3[j] || 0) + r * r;
						}
					}
				}
				i = _r3.length;
				while (--i > -1) {
					_r3[i] = Math.sqrt(_r3[i]);
				}
			}
			i = props.length;
			j = quadratic ? 4 : 1;
			while (--i > -1) {
				p = props[i];
				a = obj[p];
				_calculateControlPoints(a, curviness, quadratic, basic, _corProps[p]); //this method requires that _parseAnchors() and _setSegmentRatios() ran first so that _r1, _r2, and _r3 values are populated for all properties
				if (seamless) {
					a.splice(0, j);
					a.splice(a.length - j, j);
				}
			}
			return obj;
		}
		
		public static function _parseBezierData(values:Array, type:String, prepend:Object):Object {
			type = type || "soft";
			var obj:Object = {},
				inc:Number = (type === "cubic") ? 3 : 2,
				soft:Boolean = (type === "soft"),
				a:Number, b:Number, c:Number, d:Number, cur:Array, props:Array, i:Number, j:Number, l:Number, p:String, cnt:Number, tmp:Object;
			if (soft && prepend) {
				values = [prepend].concat(values);
			}
			if (values == null || values.length < inc + 1) { trace("invalid Bezier data"); }
			props = [];
			for (p in values[0]) {
				props.push(p);
			}
			
			i = props.length;
			while (--i > -1) {
				p = props[i];
				obj[p] = cur = [];
				cnt = 0;
				
				l = values.length;
				for (j = 0; j < l; j++) {
					a = (prepend == null) ? values[j][p] : (typeof( (tmp = values[j][p]) ) === "string" && tmp.charAt(1) === "=") ? prepend[p] + Number(tmp.charAt(0) + tmp.substr(2)) : Number(tmp);
					if (soft) if (j > 1) if (j < l - 1) {
						cur[cnt++] = (a + cur[cnt-2]) / 2;
					}
					cur[cnt++] = a;
				}
				
				l = cnt - inc + 1;
				cnt = 0;
				for (j = 0; j < l; j += inc) {
					a = cur[j];
					b = cur[j+1];
					c = cur[j+2];
					d = (inc === 2) ? 0 : cur[j+3];
					cur[cnt++] = (inc === 3) ? new Segment(a, b, c, d) : new Segment(a, (2 * b + a) / 3, (2 * b + c) / 3, c);
				}
				cur.length = cnt;
			}
			return obj;
		}
		
		private static function _parseAnchors(values:Array, p:String, correlate:Boolean, prepend:Object):Array {
			var a:Array = [],
				l:Number, i:Number, p1:Number, p2:Number, p3:Number, tmp:Object;
			if (prepend) {
				values = [prepend].concat(values);
				i = values.length;
				while (--i > -1) {
					if (typeof( (tmp = values[i][p]) ) === "string") if (tmp.charAt(1) === "=") {
						values[i][p] = prepend[p] + Number(tmp.charAt(0) + tmp.substr(2)); //accommodate relative values. Do it inline instead of breaking it out into a function for speed reasons
					}
				}
			}
			
			l = values.length - 2;
			if (l < 0) {
				a[0] = new Segment(values[0][p], 0, 0, values[(l < -1) ? 0 : 1][p]);
				return a;
			}
			
			for (i = 0; i < l; i++) {
				p1 = values[i][p];
				p2 = values[i+1][p];
				a[i] = new Segment(p1, 0, 0, p2);
				if (correlate) {
					p3 = values[i+2][p];
					_r1[i] = (_r1[i] || 0) + (p2 - p1) * (p2 - p1);
					_r2[i] = (_r2[i] || 0) + (p3 - p2) * (p3 - p2); 
				}
			}
			a[i] = new Segment(values[i][p], 0, 0, values[i+1][p]);
			return a;
		}
		
		private static function _calculateControlPoints(a:Array, curviness:Number, quad:Boolean, basic:Boolean, correlate:Boolean):Void {
			var l:Number = a.length - 1,
				ii:Number = 0,
				cp1:Number = a[0].a,
				i:Number, p1:Number, p2:Number, p3:Number, seg:Segment, m1:Number, m2:Number, mm:Number, cp2:Number, qb:Array, r1:Number, r2:Number, tl:Number;
			for (i = 0; i < l; i++) {
				seg = a[ii];
				p1 = seg.a;
				p2 = seg.d;
				p3 = a[ii+1].d;
				
				if (correlate) {
					r1 = _r1[i];
					r2 = _r2[i];
					tl = ((r2 + r1) * curviness * 0.25) / (basic ? 0.5 : _r3[i] || 0.5);
					m1 = p2 - (p2 - p1) * (basic ? curviness * 0.5 : (r1 !== 0 ? tl / r1 : 0));
					m2 = p2 + (p3 - p2) * (basic ? curviness * 0.5 : (r2 !== 0 ? tl / r2 : 0));
					mm = p2 - (m1 + (((m2 - m1) * ((r1 * 3 / (r1 + r2)) + 0.5) / 4) || 0));
				} else {
					m1 = p2 - (p2 - p1) * curviness * 0.5;
					m2 = p2 + (p3 - p2) * curviness * 0.5;
					mm = p2 - (m1 + m2) / 2;
				}
				m1 += mm;
				m2 += mm;
				
				seg.c = cp2 = m1; 
				if (i != 0) {
					seg.b = cp1;
				} else {
					seg.b = cp1 = seg.a + (seg.c - seg.a) * 0.6; //instead of placing b on a exactly, we move it inline with c so that if the user specifies an ease like Back.easeIn or Elastic.easeIn which goes BEYOND the beginning, it will do so smoothly.
				}
				
				seg.da = p2 - p1;
				seg.ca = cp2 - p1;
				seg.ba = cp1 - p1;
				
				if (quad) {
					qb = cubicToQuadratic(p1, cp1, cp2, p2);
					a.splice(ii, 1, qb[0], qb[1], qb[2], qb[3]);
					ii += 4;
				} else {
					ii++;
				}
				
				cp1 = m2;
			}
			seg = a[ii];
			seg.b = cp1;
			seg.c = cp1 + (seg.d - cp1) * 0.4; //instead of placing c on d exactly, we move it inline with b so that if the user specifies an ease like Back.easeOut or Elastic.easeOut which goes BEYOND the end, it will do so smoothly.
			seg.da = seg.d - seg.a;
			seg.ca = seg.c - seg.a;
			seg.ba = cp1 - seg.a;
			if (quad) {
				qb = cubicToQuadratic(seg.a, cp1, seg.c, seg.d);
				a.splice(ii, 1, qb[0], qb[1], qb[2], qb[3]);
			}
		}
		
		public static function cubicToQuadratic(a:Number, b:Number, c:Number, d:Number):Array {
			var q1:Object = {a:a},
				q2:Object = {},
				q3:Object = {},
				q4:Object = {c:d},
				mab:Number = (a + b) / 2, 
				mbc:Number = (b + c) / 2, 
				mcd:Number = (c + d) / 2, 
				mabc:Number = (mab + mbc) / 2,
				mbcd:Number = (mbc + mcd) / 2,
				m8:Number = (mbcd - mabc) / 8;
			q1.b = mab + (a - mab) / 4;	
			q2.b = mabc + m8;
			q1.c = q2.a = (q1.b + q2.b) / 2;
			q2.c = q3.a = (mabc + mbcd) / 2;
			q3.b = mbcd - m8;
			q4.b = mcd + (d - mcd) / 4;
			q3.c = q4.a = (q3.b + q4.b) / 2;
			return [q1, q2, q3, q4];
		}
	
		public static function quadraticToCubic(a:Number, b:Number, c:Number):Object {
			return new Segment(a, (2 * b + a) / 3, (2 * b + c) / 3, c);
		}
		
		private static function _parseLengthData(obj:Object, precision:Number):Object {
			if (precision == null) {
				precision = 6;
			}
			var a:Array = [],
				lengths:Array = [],
				d:Number = 0,
				total:Number = 0,
				threshold:Number = precision - 1,
				segments:Array = [],
				curLS:Array = [], //current length segments array
				p:String, i:Number, l:Number, index:Number;
			for (p in obj) {
				_addCubicLengths(obj[p], a, precision);
			}
			l = a.length;
			for (i = 0; i < l; i++) {
				d += Math.sqrt(a[i]);
				index = i % precision;
				curLS[index] = d;
				if (index == threshold) {
					total += d;
					index = (i / precision) >> 0;
					segments[index] = curLS;
					lengths[index] = total;
					d = 0;
					curLS = [];
				}
			}
			return {length:total, lengths:lengths, segments:segments};
		}
		
		private static function _addCubicLengths(a:Array, steps:Array, precision:Number):Void {
			if (precision == null) {
				precision = 6;
			}
			var inc:Number = 1 / precision,
				j:Number = a.length,
				d:Number, d1:Number, s:Number, da:Number, ca:Number, ba:Number, p:Number, i:Number, inv:Number, bez:Segment, index:Number;
			while (--j > -1) {
				bez = a[j];
				s = bez.a;
				da = bez.d - s;
				ca = bez.c - s;
				ba = bez.b - s;
				d = d1 = 0;
				for (i = 1; i <= precision; i++) {
					p = inc * i;
					inv = 1 - p;
					d = d1 - (d1 = (p * p * da + 3 * inv * (p * ca + inv * ba)) * p);
					index = j * precision + i - 1;
					steps[index] = (steps[index] || 0) + d * d;
				}
			}
		}
		
		public function _kill(lookup:Object):Boolean {
			var a:Array = this._props, 
				p:String, i:Number;
			for (p in _beziers) {
				if (lookup[p] != null) {
					delete _beziers[p];
					delete _func[p];
					i = a.length;
					while (--i > -1) {
						if (a[i] === p) {
							a.splice(i, 1);
						}
					}
				}
			}
			return super._kill(lookup);
		}
		
		public function _roundProps(lookup:Object, value:Boolean):Void {
			var op:Array = this._overwriteProps,
				i:Number = op.length;
			while (--i > -1) {
				if ((lookup[op[i]] != null) || lookup.bezier || lookup.bezierThrough) {
					this._round[op[i]] = value;
				}
			}
		}
		
		
		public function setRatio(v:Number):Void {
			var segments:Number = this._segCount,
				func:Object = this._func,
				target:Object = this._target,
				notStart = (v !== this._startRatio),
				curIndex:Number, inv:Number, i:Number, p:String, b:Segment, t:Number, val:Number, l:Number, lengths:Array, curSeg:Array;
			if (this._timeRes == 0) {
				curIndex = (v < 0) ? 0 : (v >= 1) ? segments - 1 : (segments * v) >> 0;
				t = (v - (curIndex * (1 / segments))) * segments;
			} else {
				lengths = this._lengths;
				curSeg = this._curSeg;
				v *= this._length;
				i = this._li;
				//find the appropriate segment (if the currently cached one isn't correct)
				if (v > this._l2 && i < segments - 1) {
					l = segments - 1;
					while (i < l && (this._l2 = lengths[++i]) <= v) {	}
					this._l1 = lengths[i-1];
					this._li = i;
					this._curSeg = curSeg = this._segments[i];
					this._s2 = curSeg[(this._s1 = this._si = 0)];
				} else if (v < this._l1 && i > 0) {
					while (i > 0 && (this._l1 = lengths[--i]) >= v) { 	}
					if (i === 0 && v < this._l1) {
						this._l1 = 0;
					} else {
						i++;
					}
					this._l2 = lengths[i];
					this._li = i;
					this._curSeg = curSeg = this._segments[i];
					this._s1 = curSeg[(this._si = curSeg.length - 1) - 1] || 0;
					this._s2 = curSeg[this._si];
				}
				curIndex = i;
				//now find the appropriate sub-segment (we split it into the number of pieces that was defined by "precision" and measured each one)
				v -= this._l1;
				i = this._si;
				if (v > this._s2 && i < curSeg.length - 1) {
					l = curSeg.length - 1;
					while (i < l && (this._s2 = curSeg[++i]) <= v) {	}
					this._s1 = curSeg[i-1];
					this._si = i;
				} else if (v < this._s1 && i > 0) {
					while (i > 0 && (this._s1 = curSeg[--i]) >= v) {	}
					if (i === 0 && v < this._s1) {
						this._s1 = 0;
					} else {
						i++;
					}
					this._s2 = curSeg[i];
					this._si = i;
				}
				t = (i + (v - this._s1) / (this._s2 - this._s1)) * this._prec;
			}
			inv = 1 - t;
			
			i = this._props.length;
			while (--i > -1) {
				p = this._props[i];
				b = this._beziers[p][curIndex];
				val = (t * t * b.da + 3 * inv * (t * b.ca + inv * b.ba)) * t + b.a;
				if (this._round[p]) {
					val = (val + ((val > 0) ? 0.5 : -0.5)) >> 0;
				}
				if (func[p]) {
					target[p](val);
				} else {
					target[p] = val;
				}
			}
			
			if (this._autoRotate != null) {
				var ar:Array = this._autoRotate,
					b2:Segment, x1:Number, y1:Number, x2:Number, y2:Number, add:Number, conv:Number;
				i = ar.length;
				while (--i > -1) {
					p = ar[i][2];
					add = ar[i][3] || 0;
					conv = (ar[i][4] == true) ? 1 : _RAD2DEG;
					b = this._beziers[ar[i][0]][curIndex];
					b2 = this._beziers[ar[i][1]][curIndex];
					
					x1 = b.a + (b.b - b.a) * t;
					x2 = b.b + (b.c - b.b) * t;
					x1 += (x2 - x1) * t;
					x2 += ((b.c + (b.d - b.c) * t) - x2) * t;
					
					y1 = b2.a + (b2.b - b2.a) * t;
					y2 = b2.b + (b2.c - b2.b) * t;
					y1 += (y2 - y1) * t;
					y2 += ((b2.c + (b2.d - b2.c) * t) - y2) * t;
					
					val = notStart ? Math.atan2(y2 - y1, x2 - x1) * conv + add : this._initialRotations[i];
					
					if (func[p]) {
						target[p](val);
					} else {
						target[p] = val;
					}
				}
			}
			
		}
	
}