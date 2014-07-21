/**
 * VERSION: 12.1.5
 * DATE: 2014-07-19
 * AS2 (AS3 version is also available)
 * UPDATES AND DOCS AT: http://www.greensock.com
 **/
import com.greensock.core.Animation;
import com.greensock.core.SimpleTimeline;
import com.greensock.easing.Ease;

/**
 * 	TweenLite is an extremely fast, lightweight, and flexible tweening engine that serves as the foundation of 
 * 	the GreenSock Tweening Platform. A TweenLite instance handles tweening one or more numeric properties of any
 *  object over time, updating them on every frame. Sounds simple, but there's a wealth of capabilities and conveniences
 *  at your fingertips with TweenLite. 
 * 
 * <p><strong>See AS3 files for full ASDocs</strong></p>
 * 
 * <p><strong>Copyright 2008-2014, GreenSock. All rights reserved.</strong> This work is subject to the terms in <a href="http://www.greensock.com/terms_of_use.html">http://www.greensock.com/terms_of_use.html</a> or for <a href="http://www.greensock.com/club/">Club GreenSock</a> members, the software agreement that was issued with the membership.</p>
 * 
 * @author Jack Doyle, jack@greensock.com
 */
class com.greensock.TweenLite extends Animation {
		public static var version:String = "12.1.5";
		public static var defaultEase:Ease = new Ease(null, null, 1, 1);
		public static var defaultOverwrite:String = "auto";
		public static var ticker:MovieClip = Animation.ticker;
		public static var _plugins:Object = {}; 
		public static var _onPluginEvent:Function;
		private static var _tweenLookup:Object = {}; 
		private static var _cnt:Number = 0;
		private static var _reservedProps:Object = {ease:1, delay:1, overwrite:1, onComplete:1, onCompleteParams:1, onCompleteScope:1, useFrames:1, runBackwards:1, startAt:1, onUpdate:1, onUpdateParams:1, onUpdateScope:1, onStart:1, onStartParams:1, onStartScope:1, onReverseComplete:1, onReverseCompleteParams:1, onReverseCompleteScope:1, onRepeat:1, onRepeatParams:1, onRepeatScope:1, easeParams:1, yoyo:1, orientToBezier:1, immediateRender:1, repeat:1, repeatDelay:1, data:1, paused:1, reversed:1};
		private static var _overwriteLookup:Object;
		public var target:Object; 
		public var ratio:Number;
		public var _propLookup:Object;
		public var _firstPT:Object;
		public var _ease:Ease;
		private var _targets:Array;
		private var _easeType:Number;
		private var _easePower:Number;
		private var _siblings:Array;
		private var _overwrite:Number;
		private var _overwrittenProps:Object; 
		private var _notifyPluginsOfEnabled:Boolean;
		private var _startAt:TweenLite;
		
		public function TweenLite(target:Object, duration:Number, vars:Object) {
			super(duration, vars);
			
			if (!_overwriteLookup) {
				_overwriteLookup = {none:0, all:1, auto:2, concurrent:3, allOnStart:4, preexisting:5};
				_overwriteLookup["true"] = 1;
				_overwriteLookup["false"] = 0;
				_addTickListener("tick", _dumpGarbage, TweenLite);
			}
			
			ratio = 0;
			this.target = target;
			_ease = defaultEase; //temporary - we'll replace it in _init(). We need to set it here for speed purposes so that on the first render(), it doesn't throw an error. 
			
			_overwrite = (this.vars.overwrite == null) ? _overwriteLookup[defaultOverwrite] : (typeof(this.vars.overwrite) === "number") ? this.vars.overwrite >> 0 : _overwriteLookup[this.vars.overwrite];
			
			if (this.target instanceof Array && (typeof(this.target[0]) === "object" || typeof(this.target[0]) === "movieclip")) {
				_targets = this.target.concat();
				_propLookup = [];
				_siblings = [];
				var i:Number = _targets.length;
				while (--i > -1) {
					_siblings[i] = _register(_targets[i], this, false);
					if (_overwrite === 1) if (_siblings[i].length > 1) {
						_applyOverwrite(_targets[i], this, null, 1, _siblings[i]);
					}
				}
				
			} else {
				_propLookup = {};
				_siblings = _register(target, this, false);
				if (_overwrite === 1) if (_siblings.length > 1) {
					_applyOverwrite(target, this, null, 1, _siblings);
				}
			}
			
			if (this.vars.immediateRender || (duration === 0 && _delay === 0 && this.vars.immediateRender != false)) {
				render(-_delay, false, true);
			}
		}
		
		/*
		public function toString():String {
			return "[TweenLite target:" + target + ", duration:" + _duration + ", data:" + data + "]";
		}
		*/
		
		private function _init():Void {
			var immediate:Boolean = vars.immediateRender,
				i:Number, initPlugins:Boolean, pt:Object, p:String, copy:Object;
			if (vars.startAt) {
				if (_startAt != null) {
					_startAt.render(-1, true); //if we've run a startAt previously (when the tween instantiated), we should revert it so that the values re-instantiate correctly particularly for relative tweens. Without this, a TweenLite.fromTo(obj, 1, {x:"+=100"}, {x:"-=100"}), for example, would actually jump to +=200 because the startAt would run twice, doubling the relative change.
				}
				vars.startAt.overwrite = 0;
				vars.startAt.immediateRender = true;
				_startAt = new TweenLite(target, 0, vars.startAt);
				if (immediate) {
					if (_time > 0) {
						_startAt = null; //tweens that render immediately (like most from() and fromTo() tweens) shouldn't revert when their parent timeline's playhead goes backward past the startTime because the initial render could have happened anytime and it shouldn't be directly correlated to this tween's startTime. Imagine setting up a complex animation where the beginning states of various objects are rendered immediately but the tween doesn't happen for quite some time - if we revert to the starting values as soon as the playhead goes backward past the tween's startTime, it will throw things off visually. Reversion should only happen in TimelineLite/Max instances where immediateRender was false (which is the default in the convenience methods like from()).
					} else if (_duration !== 0) {
						return; //we skip initialization here so that overwriting doesn't occur until the tween actually begins. Otherwise, if you create several immediateRender:true tweens of the same target/properties to drop into a TimelineLite or TimelineMax, the last one created would overwrite the first ones because they didn't get placed into the timeline yet before the first render occurs and kicks in overwriting.
					}
				}
			} else if (vars.runBackwards && _duration !== 0) {
				//from() tweens must be handled uniquely: their beginning values must be rendered but we don't want overwriting to occur yet (when time is still 0). Wait until the tween actually begins before doing all the routines like overwriting. At that time, we should render at the END of the tween to ensure that things initialize correctly (remember, from() tweens go backwards)
				if (_startAt != null) {
					_startAt.render(-1, true);
					_startAt = null;
				} else {
					copy = {};
					for (p in vars) { //copy props into a new object and skip any reserved props, otherwise onComplete or onUpdate or onStart could fire. We should, however, permit autoCSS to go through.
						if (_reservedProps[p] == null) {
							copy[p] = vars[p];
						}
					}
					copy.overwrite = 0;
					copy.data = "isFromStart"; //we tag the tween with as "isFromStart" so that if [inside a plugin] we need to only do something at the very END of a tween, we have a way of identifying this tween as merely the one that's setting the beginning values for a "from()" tween.
					_startAt = TweenLite.to(target, 0, copy);
					if (!immediate) {
						_startAt.render(-1, true); //for tweens that aren't rendered immediately, we still need to use the _startAt to record the starting values so that we can revert to them if the parent timeline's playhead goes backward beyond the beginning, but we immediately revert the tween back otherwise the parent tween that's currently instantiating wouldn't see the wrong starting values (since they were changed by the _startAt tween) 
					} else if (_time === 0) {
						return;
					}
				}
			}
			
			if (vars.ease instanceof Ease) {
				_ease = (vars.easeParams instanceof Array) ? vars.ease.config.apply(vars.ease, vars.easeParams) : vars.ease;
			} else if (typeof(vars.ease) === "function") {
				_ease = new Ease(vars.ease, vars.easeParams);
			} else {
				_ease = defaultEase;
			}
			_easeType = _ease._type;
			_easePower = _ease._power;
			_firstPT = null;
			
			if (_targets) {
				i = _targets.length;
				while (--i > -1) {
					if ( _initProps( _targets[i], (_propLookup[i] = {}), _siblings[i], (_overwrittenProps ? _overwrittenProps[i] : null)) ) {
						initPlugins = true;
					}
				}
			} else {
				initPlugins = _initProps(target, _propLookup, _siblings, _overwrittenProps);
			}
			
			if (initPlugins) {
				_onPluginEvent("_onInitAllProps", this); //reorders the array in order of priority. Uses a static TweenPlugin method in order to minimize file size in TweenLite
			}
			if (_overwrittenProps) if (_firstPT == null) if (typeof(target) !== "function") { //if all tweening properties have been overwritten, kill the tween. If the target is a function, it's most likely a delayedCall so let it live.
				_enabled(false, false);
			}
			if (vars.runBackwards) {
				pt = _firstPT;
				while (pt) {
					pt.s += pt.c;
					pt.c = -pt.c;
					pt = pt._next;
				}
			}
			_onUpdate = vars.onUpdate;
			_initted = true;
		}
		
		private function _initProps(target:Object, propLookup:Object, siblings:Array, overwrittenProps:Object):Boolean {
			var p:String, i:Number, initPlugins:Boolean, plugin:Object, val;
			if (target == null) {
				return false;
			}
			for (p in vars) {
				val = vars[p];
				if (_reservedProps[p]) { 
					if (val instanceof Array) if (val.join("").indexOf("{self}") !== -1) {
						vars[p] = _swapSelfInParams(val);
					}
					
				} else if (_plugins[p] && (plugin = new _plugins[p]())._onInitTween(target, vars[p], this)) {
					
					//t - target 		[object]
					//p - property 		[string]
					//s - start			[number]
					//c - change		[number]
					//f - isFunction	[boolean]
					//n - name			[string]
					//pg - isPlugin 	[boolean]
					//pr - priority		[number]
					_firstPT = {_next:_firstPT, t:plugin, p:"setRatio", s:0, c:1, f:true, n:p, pg:true, pr:plugin._priority};
					i = plugin._overwriteProps.length;
					while (--i > -1) {
						propLookup[plugin._overwriteProps[i]] = _firstPT;
					}
					if (plugin._priority || plugin._onInitAllProps) {
						initPlugins = true;
					}
					if (plugin._onDisable || plugin._onEnable) {
						_notifyPluginsOfEnabled = true;
					}
					
				} else {
					_firstPT = propLookup[p] = {_next:_firstPT, t:target, p:p, f:(typeof(target[p]) === "function"), n:p, pg:false, pr:0};
					_firstPT.s = (!_firstPT.f) ? Number(target[p]) : target[ ((p.indexOf("set") || typeof(target["get" + p.substr(3)]) !== "function") ? p : "get" + p.substr(3)) ]();
					_firstPT.c = (typeof(val) === "number") ? Number(val) - _firstPT.s : (typeof(val) === "string" && val.charAt(1) === "=") ? Number(val.charAt(0)+"1") * Number(val.substr(2)) : Number(val) || 0;
				}
				if (_firstPT) if (_firstPT._next) {
					_firstPT._next._prev = _firstPT;
				}
			}
			
			if (overwrittenProps) if (_kill(overwrittenProps, target)) { //another tween may have tried to overwrite properties of this tween before init() was called (like if two tweens start at the same time, the one created second will run first)
				return _initProps(target, propLookup, siblings, overwrittenProps);
			}
			if (_overwrite > 1) if (_firstPT) if (siblings.length > 1) if (_applyOverwrite(target, this, propLookup, _overwrite, siblings)) {
				_kill(propLookup, target);
				return _initProps(target, propLookup, siblings, overwrittenProps);
			}
			return initPlugins;
		}
		
		public function render(time:Number, suppressEvents:Boolean, force:Boolean):Void {
			var isComplete:Boolean, callback:String, pt:Object, rawPrevTime:Number, prevTime:Number = _time;
			if (time >= _duration) {
				_totalTime = _time = _duration;
				ratio = _ease._calcEnd ? _ease.getRatio(1) : 1;
				if (!_reversed) {
					isComplete = true;
					callback = "onComplete";
				}
				if (_duration === 0) { //zero-duration tweens are tricky because we must discern the momentum/direction of time in order to determine whether the starting values should be rendered or the ending values. If the "playhead" of its timeline goes past the zero-duration tween in the forward direction or lands directly on it, the end values should be rendered, but if the timeline's "playhead" moves past it in the backward direction (from a postitive time to a negative time), the starting values must be rendered.
					rawPrevTime = _rawPrevTime;
					if (_startTime === _timeline._duration) { //if a zero-duration tween is at the VERY end of a timeline and that timeline renders at its end, it will typically add a tiny bit of cushion to the render time to prevent rounding errors from getting in the way of tweens rendering their VERY end. If we then reverse() that timeline, the zero-duration tween will trigger its onReverseComplete even though technically the playhead didn't pass over it again. It's a very specific edge case we must accommodate.
						time = 0;
					}
					if (time === 0 || rawPrevTime < 0 || rawPrevTime === _tinyNum) if (rawPrevTime !== time) {
						force = true;
						if (rawPrevTime > _tinyNum) {
							callback = "onReverseComplete";
						}
					}
					_rawPrevTime = rawPrevTime = (!suppressEvents || time !== 0 || rawPrevTime === time) ? time : _tinyNum; //when the playhead arrives at EXACTLY time 0 (right on top) of a zero-duration tween, we need to discern if events are suppressed so that when the playhead moves again (next time), it'll trigger the callback. If events are NOT suppressed, obviously the callback would be triggered in this render. Basically, the callback should fire either when the playhead ARRIVES or LEAVES this exact spot, not both. Imagine doing a timeline.seek(0) and there's a callback that sits at 0. Since events are suppressed on that seek() by default, nothing will fire, but when the playhead moves off of that position, the callback should fire. This behavior is what people intuitively expect. We set the _rawPrevTime to be a precise tiny number to indicate this scenario rather than using another property/variable which would increase memory usage. This technique is less readable, but more efficient.
				}
				
			} else if (time < 0.0000001) { //to work around occasional floating point math artifacts, round super small values to 0. 
				_totalTime = _time = 0;
				ratio = _ease._calcEnd ? _ease.getRatio(0) : 0;
				if (prevTime !== 0 || (_duration === 0 && _rawPrevTime > 0 && _rawPrevTime !== _tinyNum)) {
					callback = "onReverseComplete";
					isComplete = _reversed;
				}
				if (time < 0) {
					_active = false;
					if (_duration === 0) { //zero-duration tweens are tricky because we must discern the momentum/direction of time in order to determine whether the starting values should be rendered or the ending values. If the "playhead" of its timeline goes past the zero-duration tween in the forward direction or lands directly on it, the end values should be rendered, but if the timeline's "playhead" moves past it in the backward direction (from a postitive time to a negative time), the starting values must be rendered.
						if (_rawPrevTime >= 0) {
							force = true;
						}
						_rawPrevTime = rawPrevTime = (!suppressEvents || time !== 0 || _rawPrevTime === time) ? time : _tinyNum; //when the playhead arrives at EXACTLY time 0 (right on top) of a zero-duration tween, we need to discern if events are suppressed so that when the playhead moves again (next time), it'll trigger the callback. If events are NOT suppressed, obviously the callback would be triggered in this render. Basically, the callback should fire either when the playhead ARRIVES or LEAVES this exact spot, not both. Imagine doing a timeline.seek(0) and there's a callback that sits at 0. Since events are suppressed on that seek() by default, nothing will fire, but when the playhead moves off of that position, the callback should fire. This behavior is what people intuitively expect. We set the _rawPrevTime to be a precise tiny number to indicate this scenario rather than using another property/variable which would increase memory usage. This technique is less readable, but more efficient.
					}
				} else if (!_initted) { //if we render the very beginning (time == 0) of a fromTo(), we must force the render (normal tweens wouldn't need to render at a time of 0 when the prevTime was also 0). This is also mandatory to make sure overwriting kicks in immediately.
					force = true;
				}
				
			} else {
				_totalTime = _time = time;
				
				if (_easeType) {
					var r:Number = time / _duration, type:Number = _easeType, pow:Number = _easePower;
					if (type === 1 || (type === 3 && r >= 0.5)) {
						r = 1 - r;
					}
					if (type === 3) {
						r *= 2;
					}
					if (pow === 1) {
						r *= r;
					} else if (pow === 2) {
						r *= r * r;
					} else if (pow === 3) {
						r *= r * r * r;
					} else if (pow === 4) {
						r *= r * r * r * r;
					}
					
					if (type === 1) {
						ratio = 1 - r;
					} else if (type === 2) {
						ratio = r;
					} else if (time / _duration < 0.5) {
						ratio = r / 2;
					} else {
						ratio = 1 - (r / 2);
					}
					
				} else {
					ratio = _ease.getRatio(time / _duration);
				}
				
			}
			
			if (_time === prevTime && !force) {
				return;
			} else if (!_initted) {
				_init();
				if (!_initted || _gc) { //immediateRender tweens typically won't initialize until the playhead advances (_time is greater than 0) in order to ensure that overwriting occurs properly. Also, if all of the tweening properties have been overwritten (which would cause _gc to be true, as set in _init()), we shouldn't continue otherwise an onStart callback could be called for example. 
					return;
				}
				//_ease is initially set to defaultEase, so now that init() has run, _ease is set properly and we need to recalculate the ratio. Overall this is faster than using conditional logic earlier in the method to avoid having to set ratio twice because we only init() once but renderTime() gets called VERY frequently.
				if (_time && !isComplete) {
					ratio = _ease.getRatio(_time / _duration);
				} else if (isComplete && _ease._calcEnd) {
					ratio = _ease.getRatio((_time === 0) ? 0 : 1);
				}
			}
			
			if (!_active) if (!_paused && _time !== prevTime && time >= 0) {
				_active = true;  //so that if the user renders a tween (as opposed to the timeline rendering it), the timeline is forced to re-render and align it with the proper time/frame on the next rendering cycle. Maybe the tween already finished but the user manually re-renders it as halfway done.
			}
			if (prevTime === 0) {
				if (_startAt != null) {
					if (time >= 0) {
						_startAt.render(time, suppressEvents, force);
					} else if (!callback) {
						callback = "_dummyGS"; //if no callback is defined, use a dummy value just so that the condition at the end evaluates as true because _startAt should render AFTER the normal render loop when the time is negative. We could handle this in a more intuitive way, of course, but the render loop is the MOST important thing to optimize, so this technique allows us to avoid adding extra conditional logic in a high-frequency area.
					}
				}
				if (vars.onStart) if (_time !== 0 || _duration === 0) if (!suppressEvents) {
					vars.onStart.apply(vars.onStartScope || this, vars.onStartParams);
				}
			}
			
			pt = _firstPT;
			while (pt) {
				if (pt.f) {
					pt.t[pt.p](pt.c * ratio + pt.s);
				} else {
					pt.t[pt.p] = pt.c * ratio + pt.s;
				}
				pt = pt._next;
			}
			
			if (_onUpdate != null) {
				if (time < 0 && _startAt != null && _startTime != 0) { //if the tween is positioned at the VERY beginning (_startTime 0) of its parent timeline, it's illegal for the playhead to go back further, so we should not render the recorded startAt values.
					_startAt.render(time, suppressEvents, force); //note: for performance reasons, we tuck this conditional logic inside less traveled areas (most tweens don't have an onUpdate). We'd just have it at the end before the onComplete, but the values should be updated before any onUpdate is called, so we ALSO put it here and then if it's not called, we do so later near the onComplete.
				}
				if (!suppressEvents) if (_time !== prevTime || isComplete) {
					_onUpdate.apply(vars.onUpdateScope || this, vars.onUpdateParams);
				}
			}
			
			if (callback) if (!_gc) { //check _gc because there's a chance that kill() could be called in an onUpdate
				if (time < 0 && _startAt != null && _onUpdate == null && _startTime != 0) { //if the tween is positioned at the VERY beginning (_startTime 0) of its parent timeline, it's illegal for the playhead to go back further, so we should not render the recorded startAt values.
					_startAt.render(time, suppressEvents, force);
				}
				if (isComplete) {
					if (_timeline.autoRemoveChildren) {
						_enabled(false, false);
					}
					_active = false;
				}
				if (!suppressEvents) if (vars[callback]) {
					vars[callback].apply(vars[callback + "Scope"] || this, vars[callback + "Params"]);
				}
				if (_duration === 0 && _rawPrevTime === _tinyNum && rawPrevTime !== _tinyNum) { //the onComplete or onReverseComplete could trigger movement of the playhead and for zero-duration tweens (which must discern direction) that land directly back on their start time, we don't want to fire again on the next render. Think of several addPause()'s in a timeline that forces the playhead to a certain spot, but what if it's already paused and another tween is tweening the "time" of the timeline? Each time it moves [forward] past that spot, it would move back, and since suppressEvents is true, it'd reset _rawPrevTime to _tinyNum so that when it begins again, the callback would fire (so ultimately it could bounce back and forth during that tween). Again, this is a very uncommon scenario, but possible nonetheless.
					_rawPrevTime = 0;
				}
			}
			
		}
		
		public function _kill(vars:Object, target:Object):Boolean {
			if (vars === "all") {
				vars = null;
			}
			if (vars == null) if (target == null || target == this.target) {
				return _enabled(false, false);
			}
			target = target || _targets || this.target;
			var i:Number, overwrittenProps:Object, p:String, pt:Object, propLookup:Object, changed:Boolean, killProps:Object, record:Boolean;
			if (target instanceof Array && (typeof(target[0]) === "object" || typeof(target[0]) === "movieclip")) {
				i = target.length;
				while (--i > -1) {
					if (_kill(vars, target[i])) {
						changed = true;
					}
				}
			} else {
				if (_targets) {
					i = _targets.length;
					while (--i > -1) {
						if (target === _targets[i]) {
							propLookup = _propLookup[i] || {};
							_overwrittenProps = _overwrittenProps || [];
							overwrittenProps = _overwrittenProps[i] = vars ? _overwrittenProps[i] || {} : "all";
							break;
						}
					}
				} else if (target !== this.target) {
					return false;
				} else {
					propLookup = _propLookup;
					overwrittenProps = _overwrittenProps = vars ? _overwrittenProps || {} : "all";
				}
				
				if (propLookup) {
					killProps = vars || propLookup;
					record = (vars != overwrittenProps && overwrittenProps != "all" && vars != propLookup && (typeof(vars) != "object" || vars._tempKill != true)); //_tempKill is a super-secret way to delete a particular tweening property but NOT have it remembered as an official overwritten property (like in BezierPlugin)
					for (p in killProps) {
						if ((pt = propLookup[p])) {
							if (pt.pg && pt.t._kill(killProps)) {
								changed = true; //some plugins need to be notified so they can perform cleanup tasks first
							}
							if (!pt.pg || pt.t._overwriteProps.length === 0) {
								if (pt._prev) {
									pt._prev._next = pt._next;
								} else if (pt == _firstPT) {
									_firstPT = pt._next;
								}
								if (pt._next) {
									pt._next._prev = pt._prev;
								}
								pt._next = pt._prev = null;
							}
							delete propLookup[p];
						}
						if (record) { 
							overwrittenProps[p] = 1;
						}
					}
					if (_firstPT == null && _initted) { //if all tweening properties are killed, kill the tween. Without this line, if there's a tween with multiple targets and then you killTweensOf() each target individually, the tween would technically still remain active and fire its onComplete even though there aren't any more properties tweening. 
						_enabled(false, false);
					}
				}
			}
			return changed;
		}
		
		public function invalidate() {
			if (_notifyPluginsOfEnabled) {
				_onPluginEvent("_onDisable", this);
			}
			_firstPT = null;
			_overwrittenProps = null;
			_onUpdate = null;
			_startAt = null;
			_initted = _active = _notifyPluginsOfEnabled = false;
			_propLookup = (_targets) ? {} : [];
			return this;
		}
		
		public function _enabled(enabled:Boolean, ignoreTimeline:Boolean):Boolean {
			if (enabled && _gc) {
				if (_targets) {
					var i:Number = _targets.length;
					while (--i > -1) {
						_siblings[i] = _register(_targets[i], this, true);
					}
				} else {
					_siblings = _register(target, this, true);
				}
			}
			super._enabled(enabled, ignoreTimeline);
			if (_notifyPluginsOfEnabled) if (_firstPT) {
				return _onPluginEvent(((enabled) ? "_onEnable" : "_onDisable"), this);
			}
			return false;
		}
		
		
//---- STATIC FUNCTIONS -----------------------------------------------------------------------------------
		
		public static function to(target:Object, duration:Number, vars:Object):TweenLite {
			return new TweenLite(target, duration, vars);
		}
		
		public static function from(target:Object, duration:Number, vars:Object):TweenLite {
			vars.runBackwards = true;
			if (vars.immediateRender != false) {
				vars.immediateRender = true;
			}
			return new TweenLite(target, duration, vars);
		}
		
		public static function fromTo(target:Object, duration:Number, fromVars:Object, toVars:Object):TweenLite {
			toVars.startAt = fromVars;
			toVars.immediateRender = (toVars.immediateRender != false && fromVars.immediateRender != false);
			return new TweenLite(target, duration, toVars);
		}
		
		public static function delayedCall(delay:Number, callback:Function, params:Array, scope:Object, useFrames:Boolean):TweenLite {
			return new TweenLite(callback, 0, {delay:delay, onComplete:callback, onCompleteParams:params, onCompleteScope:scope, onReverseComplete:callback, onReverseCompleteParams:params, onReverseCompleteScope:scope, immediateRender:false, useFrames:useFrames, overwrite:0});
		}
		
		private static function _dumpGarbage():Void {
			if (!(_rootFrame % 60)) {
				var i:Number, a:Array, p:String;
				for (p in _tweenLookup) {
					a = _tweenLookup[p].tweens;
					i = a.length;
					while (--i > -1) {
						if (a[i]._gc) {
							a.splice(i, 1);
						}
					}
					if (a.length === 0) {
						delete _tweenLookup[p];
					}
				}
			}
		}
		
		public static function set(target:Object, vars:Object):TweenLite {
			return new TweenLite(target, 0, vars);
		}

		public static function killTweensOf(target:Object, onlyActive, vars:Object):Void {
			if (typeof(onlyActive) === "object") {
				vars = onlyActive; //for backwards compatibility (before "onlyActive" parameter was inserted)
				onlyActive = false;
			}
			var a:Array = getTweensOf(target, onlyActive),
				i:Number = a.length;
			while (--i > -1) {
				a[i]._kill(vars, target);
			}
		}
		
		public static function killDelayedCallsTo(func:Function):Void {
			killTweensOf(func);
		}
		
		public static function getTweensOf(target:Object, onlyActive:Boolean):Array {
			var i:Number, a:Array, j:Number, t:TweenLite;
			if (target instanceof Array && (typeof(target[0]) === "object" || typeof(target[0]) === "movieclip")) {
				i = target.length;
				a = [];
				while (--i > -1) {
					a = a.concat(getTweensOf(target[i], onlyActive));
				}
				i = a.length;
				//now get rid of any duplicates (tweens of arrays of objects could cause duplicates)
				while (--i > -1) {
					t = a[i];
					j = i;
					while (--j > -1) {
						if (t === a[j]) {
							a.splice(i, 1);
						}
					}
				}
			} else {
				a = _register(target).concat();
				i = a.length;
				while (--i > -1) {
					if (a[i]._gc || (onlyActive && !a[i].isActive())) {
						a.splice(i, 1);
					}
				}
			}
			return a;
		}
		
		private static function _register(target:Object, tween:TweenLite, scrub:Boolean):Array {
			var id:String, i:Number, a:Array, p:String, tl:Object = _tweenLookup;
			if (typeof(target) === "movieclip") {
				id = String(target);
			} else {
				for (p in tl) {
					if (tl[p].target === target) {
						id = p;
						break;
					}
				}
			}
			if (!tl[id || (id = "t" + (_cnt++))]) {
				tl[id] = {target:target, tweens:[]};
			}
			if (tween) {
				a = tl[id].tweens;
				a[(i = a.length)] = tween;
				if (scrub) {
					while (--i > -1) {
						if (a[i] === tween) {
							a.splice(i, 1);
						}
					}
				}
			}
			return tl[id].tweens;
		}
		
		private static function _applyOverwrite(target:Object, tween:TweenLite, props:Object, mode:Number, siblings:Array):Boolean {
			var i:Number, changed:Boolean, curTween:TweenLite;
			if (mode === 1 || mode >= 4) {
				var l:Number = siblings.length;
				for (i = 0; i < l; i++) {
					if ((curTween = siblings[i]) !== tween) {
						if (!curTween._gc) if (curTween._enabled(false, false)) {
							changed = true;
						}
					} else if (mode === 5) {
						break;
					}
				}
				return changed;
			}
			//NOTE: Add 0.0000000001 to overcome floating point errors that can cause the startTime to be VERY slightly off (when a tween's time() is set for example)
			var startTime:Number = tween._startTime + 0.0000000001, overlaps:Array = [], oCount:Number = 0, zeroDur:Boolean = (tween._duration == 0), globalStart:Number;
			i = siblings.length;
			while (--i > -1) {
				if ((curTween = siblings[i]) === tween || curTween._gc || curTween._paused) {
					//ignore
				} else if (curTween._timeline != tween._timeline) {
					globalStart = globalStart || _checkOverlap(tween, 0, zeroDur);
					if (_checkOverlap(curTween, globalStart, zeroDur) === 0) {
						overlaps[oCount++] = curTween;
					}
				} else if (curTween._startTime <= startTime) if (curTween._startTime + curTween.totalDuration() / curTween._timeScale > startTime) if (!((zeroDur || !curTween._initted) && startTime - curTween._startTime <= 0.0000000002)) {
					overlaps[oCount++] = curTween;
				}
			}
			
			i = oCount;
			while (--i > -1) {
				curTween = overlaps[i];
				if (mode === 2) if (curTween._kill(props, target)) {
					changed = true;
				}
				if (mode !== 2 || (!curTween._firstPT && curTween._initted)) { 
					if (curTween._enabled(false, false)) { //if all property tweens have been overwritten, kill the tween.
						changed = true;
					}
				}
			}
			return changed;
		}
		
		private static function _checkOverlap(tween:Animation, reference:Number, zeroDur:Boolean):Number {
			var tl:SimpleTimeline = tween._timeline, 
				ts:Number = tl._timeScale, 
				t:Number = tween._startTime,
				min:Number = 0.0000000001;
			while (tl._timeline) {
				t += tl._startTime;
				ts *= tl._timeScale;
				if (tl._paused) {
					return -100;
				}
				tl = tl._timeline;
			}
			t /= ts;
			return (t > reference) ? t - reference : ((zeroDur && t == reference) || (!tween._initted && t - reference < 2 * min)) ? min : ((t += tween.totalDuration() / tween._timeScale / ts) > reference + min) ? 0 : t - reference - min;
		}
		
	
}
