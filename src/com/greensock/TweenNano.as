/**
 * VERSION: 12.0.0
 * DATE: 2013-01-21
 * AS2 (AS3 is also available)
 * UPDATES AND DOCS AT: http://www.greensock.com
 **/

/**
 * TweenNano is a super-lightweight (2k in AS3 and 2.4k in AS2) version of <a href="http://www.greensock.com/tweenlite/">TweenLite</a> 
 * and is only recommended for situations where you absolutely cannot afford the extra 4.7k that the normal 
 * TweenLite engine would cost and your project doesn't require any plugins. Normally, it is much better to 
 * use TweenLite because of the additional flexibility it provides via plugins and its compatibility with 
 * TimelineLite and TimelineMax. 
 * 
 * <p><strong>See AS3 files for full ASDocs</strong></p>
 * 
 * <p><strong>Copyright 2008-2014, GreenSock. All rights reserved.</strong> This work is subject to the terms in <a href="http://www.greensock.com/terms_of_use.html">http://www.greensock.com/terms_of_use.html</a> or for <a href="http://www.greensock.com/club/">Club GreenSock</a> members, the software agreement that was issued with the membership.</p>
 * 
 * @author Jack Doyle, jack@greensock.com
 */	 
class com.greensock.TweenNano {
		public static var version:String = "12.0.0";
		private static var _time:Number;
		private static var _frame:Number;
		private static var _reservedProps:Object;
		private static var _first:TweenNano;
		private static var _last:TweenNano;
		private static var _onTick:Array = [];
		public static var ticker:MovieClip = _jumpStart(_root);
		public static var defaultEase:Object =  function(t:Number, b:Number, c:Number, d:Number):Number { return -1 * (t /= d) * (t - 2); };
		public var target:Object;
		public var vars:Object; 
		public var ratio:Number = 0;
		public var _duration:Number; 
		public var _startTime:Number;
		public var _gc:Boolean;
		public var _useFrames:Boolean;
		public var _next:TweenNano;
		public var _prev:TweenNano;
		public var _targets:Array;
		private var _ease:Function;
		private var _rawEase:Object;
		private var _initted:Boolean;
		private var _firstPT:Object;
		
		public function TweenNano(target:Object, duration:Number, vars:Object) {
			if (!_reservedProps) {
				_reservedProps = {ease:1, delay:1, useFrames:1, overwrite:1, onComplete:1, onCompleteParams:1, onCompleteScope:1, runBackwards:1, immediateRender:1, onUpdate:1, onUpdateParams:1, onUpdateScope:1, startAt:1};
				_time = getTimer() / 1000;
				_frame = 0;
				_addTickListener("tick", _updateRoot, TweenNano);
			}
			if (ticker.onEnterFrame !== _tick) { //subloaded swfs in Flash Lite restrict access to _root.createEmptyMovieClip(), so we find the subloaded swf MovieClip to createEmptyMovieClip(), but if it gets unloaded, the onEnterFrame will stop running so we need to check each time a tween is created.
				_jumpStart(_root);
			}
			
			this.vars = vars;
			_duration = duration;
			this.target = target;
			if (target instanceof Array && (typeof(target[0]) === "object" || typeof(target[0]) === "movieclip")) {
				_targets = target.concat();
			}
			_rawEase = this.vars.ease || defaultEase;
			_ease = (typeof(_rawEase) == "function") ? Function(_rawEase) : _rawEase.getRatio;
			_useFrames = (vars.useFrames == true);
			_startTime = (_useFrames ? _frame : _time) + (this.vars.delay || 0);
			
			if (this.vars.overwrite == "all" || int(this.vars.overwrite) == 1) { 
				killTweensOf(this.target);
			}
			
			_prev = _last;
			if (_last) {
				_last._next = this;
			} else {
				_first = this;
			}
			_last = this;
			
			if (this.vars.immediateRender == true || (duration == 0 && this.vars.delay == 0 && this.vars.immediateRender != false)) {
				_render(0);
			}
		}

		private static function _addTickListener(type:String, callback:Function, scope:Object, useParam:Boolean, priority:Number):Void {
			if (type === "tick") {
				priority = priority || 0;
				var i:Number = _onTick.length, index:Number = 0, l:Object;
				while (--i > -1) {
					if ((l = _onTick[i]).c === callback) {
						_onTick.splice(i, 1);
					} else if (index === 0 && l.p < priority) {
						index = i + 1;
					}
				}
				_onTick.splice(index, 0, {c:callback, s:scope, up:useParam, p:priority});
			}
		}
		
		private static function _removeTickListener(type:String, callback:Function):Void {
			var i:Number = _onTick.length;
			while (--i > -1) {
				if (_onTick[i].c === callback && type === "tick") {
					_onTick.splice(i, 1);
					return;
				}
			}
		}
		
		private static function _tick():Void {
			var i:Number = _onTick.length, l:Object;
			while (--i > -1) {
				if ((l = _onTick[i]).up) {
					l.c.call(l.s, {type:"tick", target:ticker});
				} else {
					l.c.call(l.s);
				}
			}
		}
		
		private static function _findSubloadedSWF(mc:MovieClip):MovieClip {
			for (var p:String in mc) {
				if (typeof(mc[p]) == "movieclip") {
					if (mc[p]._url != _root._url && mc[p].getBytesLoaded() != undefined) {
						return mc[p];
					} else if (_findSubloadedSWF(mc[p])) {
						return _findSubloadedSWF(mc[p]);
					}
				}
			}
			return undefined;
		}
		
		public static function _jumpStart(root:MovieClip):MovieClip {
			if (ticker != undefined) {
				ticker.removeMovieClip();
			}
			var mc:MovieClip = (root.getBytesLoaded() == undefined) ? _findSubloadedSWF(root) : root; //subloaded swfs won't return getBytesLoaded() in Flash Lite, and it locks us out from being able to createEmptyMovieClip(), so we must find the subloaded clip to do it there instead.
			var l:Number = 999; //Don't just do getNextHighestDepth() because often developers will hard-code stuff that uses low levels which would overwrite the TweenLite clip. Start at level 999 and make sure nothing's there. If there is, move up until we find an empty level.
			while (mc.getInstanceAtDepth(l)) {
				l++;
			}
			ticker = mc.createEmptyMovieClip("_gsTweenNano" + String(version).split(".").join("_"), l);
			ticker.onEnterFrame = _tick;
			ticker.addEventListener = _addTickListener;
			ticker.removeEventListener = _removeTickListener;
			return ticker;
		}
		
		public function _init():Void {
			if (vars.startAt) {
				vars.startAt.immediateRender = true;
				TweenNano.to(target, 0, vars.startAt);
			}
			var i:Number, pt:Object;
			if (_targets != null) {
				i = _targets.length;
				while (--i > -1) {
					_initProps(_targets[i]);
				}
			} else {
				_initProps(target);
			}
			if (vars.runBackwards) {
				pt = _firstPT;
				while (pt) {
					pt.s += pt.c;
					pt.c = -pt.c;
					pt = pt._next;
				}
			}
			_initted = true;
		}
		
		private function _initProps(target):Void {
			if (target != null) {
				for (var p:String in vars) {
					if (!_reservedProps[p]) {
						_firstPT = {_next:_firstPT, t:target, p:p, f:(typeof(target[p]) === "function")};
						_firstPT.s = (!_firstPT.f) ? Number(target[p]) : target[ ((p.indexOf("set") || typeof(target["get" + p.substr(3)]) !== "function") ? p : "get" + p.substr(3)) ]();
						_firstPT.c = (typeof(vars[p]) === "number") ? Number(vars[p]) - _firstPT.s : (typeof(vars[p]) === "string" && vars[p].charAt(1) === "=") ? Number(vars[p].charAt(0)+"1") * Number(vars[p].substr(2)) : Number(vars[p]) || 0;
						if (_firstPT._next) {
							_firstPT._next._prev = _firstPT;
						}
					}
				}
			}
		}
		
		public function _render(time:Number):Void {
			if (!_initted) {
				_init();
			}
			if (time >= _duration) {
				time = _duration;
				this.ratio = (_ease !== _rawEase && _rawEase._calcEnd) ? _ease.call(_rawEase, 1) : 1;
			} else if (time <= 0) {
				this.ratio = (_ease !== _rawEase && _rawEase._calcEnd) ? _ease.call(_rawEase, 0) : 0;
			} else {
				this.ratio = (_ease === _rawEase) ? _ease(time, 0, 1, _duration) : _ease.call(_rawEase, time / _duration);
			}
			var pt:Object = _firstPT;
			while (pt) {
				if (pt.f) {
					pt.t[pt.p](pt.c * ratio + pt.s);
				} else {
					pt.t[pt.p] = pt.c * ratio + pt.s;
				}
				pt = pt._next;
			}
			if (vars.onUpdate) {
				vars.onUpdate.apply(vars.onUpdateScope || this, vars.onUpdateParams);
			}
			if (time == _duration) {
				kill();
				if (vars.onComplete) {
					vars.onComplete.apply(vars.onCompleteScope || this, vars.onCompleteParams);
				}
			}
		}
		
		public function kill(target):Void {
			var i:Number, pt:Object = _firstPT;
			target = target || _targets || this.target;
			if (target instanceof Array && (typeof(target[0]) === "object" || typeof(target[0]) === "movieclip")) {
				i = target.length;
				while (--i > -1) {
					kill(target[i]);
				}
				return;
			} else if (_targets != null) {
				i = _targets.length; 
				while (--i > -1) {
					if (target == _targets[i]) {
						_targets.splice(i, 1);
					}
				}
				while (pt) {
					if (pt.t == target) {
						if (pt._next) {
							pt._next._prev = pt._prev;
						}
						if (pt._prev) {
							pt._prev._next = pt._next;
						} else {
							_firstPT = pt._next;
						}
					}
					pt = pt._next;
				}
			}
			if (_targets == null || _targets.length == 0) {
				_gc = true;
				if (_prev) {
					_prev._next = _next;
				} else if (this == _first) {
					_first = _next;
				}
				if (_next) {
					_next._prev = _prev;
				} else if (this == _last) {
					_last = _prev;
				}
				_next = _prev = null;
			}
		}
		
		
//---- STATIC FUNCTIONS -------------------------------------------------------------------------
		
		public static function to(target:Object, duration:Number, vars:Object):TweenNano {
			return new TweenNano(target, duration, vars);
		}
		
		public static function from(target:Object, duration:Number, vars:Object):TweenNano {
			vars.runBackwards = true;
			if (vars.immediateRender != false) {
				vars.immediateRender = true;
			}
			return new TweenNano(target, duration, vars);
		}
		
		public static function delayedCall(delay:Number, callback:Function, params:Array, scope:Object, useFrames:Boolean):TweenNano {
			return new TweenNano(callback, 0, {delay:delay, onComplete:callback, onCompleteParams:params, onCompleteScope:scope, useFrames:useFrames});
		}

		public static function _updateRoot():Void {
			_frame += 1;
			_time = getTimer() * 0.001;
			var tween:TweenNano = _first,
				next:TweenNano,
				t:Number;
			while (tween) {
				next = tween._next;
				t = (tween._useFrames) ? _frame : _time;
				if (t >= tween._startTime && !tween._gc) {
					tween._render(t - tween._startTime);
				}
				tween = next;
			}
		}
		
		public static function killTweensOf(target:Object):Void {
			var t:TweenNano = _first,
				next:TweenNano;
			while (t) {
				next = t._next;
				if (t.target == target) {
					t.kill();
				} else if (t._targets != null) {
					t.kill(target);
				}
				t = next;
			}
		}
	
}