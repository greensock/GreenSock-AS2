/**
 * VERSION: 12.0.0
 * DATE: 2013-01-21
 * AS2 (AS3 version is also available)
 * UPDATES AND DOCS AT: http://www.greensock.com 
 **/
import com.greensock.TweenLite;
import com.greensock.core.Animation;
import com.greensock.core.SimpleTimeline;
import com.greensock.plugins.*;

/**
 * TweenMax extends the extremely lightweight, fast TweenLite engine, adding many useful features
 * like timeScale, event listeners, updateTo(), yoyo, repeat, repeatDelay, rounding, and more. It also 
 * activates many extra plugins by default, making it extremely full-featured. Since TweenMax extends 
 * TweenLite, it can do ANYTHING TweenLite can do plus much more. 
 * 	  
 * <p><strong>See AS3 files for full ASDocs</strong></p>
 * 
 * <p><strong>Copyright 2008-2013, GreenSock. All rights reserved.</strong> This work is subject to the terms in <a href="http://www.greensock.com/terms_of_use.html">http://www.greensock.com/terms_of_use.html</a> or for <a href="http://www.greensock.com/club/">Club GreenSock</a> members, the software agreement that was issued with the membership.</p>
 * 
 * @author Jack Doyle, jack@greensock.com
 */
class com.greensock.TweenMax extends TweenLite {
		public static var version:String = "12.0.0";
		private static var _activatedPlugins:Boolean = TweenPlugin.activate([
			
			AutoAlphaPlugin,			//tweens _alpha and then toggles "_visible" to false if/when _alpha is zero
			EndArrayPlugin,				//tweens numbers in an Array
			FramePlugin,				//tweens MovieClip frames
			RemoveTintPlugin,			//allows you to remove a tint
			TintPlugin,					//tweens tints
			VisiblePlugin,				//tweens a target's "_visible" property
			VolumePlugin,				//tweens the volume of a MovieClip or Sound
			BevelFilterPlugin,			//tweens BevelFilters
			BezierPlugin,				//enables bezier tweening
			BezierThroughPlugin,		//enables bezierThrough tweening
			BlurFilterPlugin,			//tweens BlurFilters
			ColorMatrixFilterPlugin,	//tweens ColorMatrixFilters (including hue, saturation, colorize, contrast, brightness, and threshold)
			ColorTransformPlugin,		//tweens advanced color properties like exposure, brightness, tintAmount, redOffset, redMultiplier, etc.
			DropShadowFilterPlugin,		//tweens DropShadowFilters
			FrameLabelPlugin,			//tweens a MovieClip to particular label
			GlowFilterPlugin,			//tweens GlowFilters
			HexColorsPlugin,			//tweens hex colors
			RoundPropsPlugin,			//enables the roundProps special property for rounding values
			ShortRotationPlugin			//tweens rotation values in the shortest direction
			
			]); //activated in static var instead of constructor because otherwise if there's a from() tween, TweenLite's constructor would get called first and initTweenVals() would run before the plugins were activated.
		
		public static var killTweensOf:Function = TweenLite.killTweensOf;
		public static var killDelayedCallsTo:Function = TweenLite.killTweensOf;
		public static var getTweensOf:Function = TweenLite.getTweensOf;
		public static var ticker:MovieClip = Animation.ticker;
		private var _repeat:Number;
		private var _repeatDelay:Number;
		private var _cycle:Number;
		private var _yoyo:Boolean;
		
		public function TweenMax(target:Object, duration:Number, vars:Object) {
			super(target, duration, vars);
			_cycle = 0;
			_yoyo = (this.vars.yoyo == true);
			_repeat = this.vars.repeat || 0;
			_repeatDelay = this.vars.repeatDelay || 0;
			_dirty = true; //ensures that if there is any repeat, the totalDuration will get recalculated to accurately report it.
		}
	
		public function invalidate() {
			_yoyo = (this.vars.yoyo == true);
			_repeat = this.vars.repeat || 0;
			_repeatDelay = this.vars.repeatDelay || 0;
			_uncache(true);
			return super.invalidate();
		}
		
		public function updateTo(vars:Object, resetDuration:Boolean) {
			var curRatio:Number = ratio;
			if (resetDuration) if (timeline != null) if (_startTime < _timeline._time) {
				_startTime = _timeline._time;
				_uncache(false);
				if (_gc) {
					_enabled(true, false);
				} else {
					_timeline.insert(this, _startTime - _delay); //ensures that any necessary re-sequencing of Animations in the timeline occurs to make sure the rendering order is correct.
				}
			}
			for (var p:String in vars) {
				this.vars[p] = vars[p];
			}
			if (_initted) {
				if (resetDuration) {
					_initted = false;
				} else {
					if (_notifyPluginsOfEnabled && _firstPT) {
						_onPluginEvent("_onDisable", this); //in case a plugin like MotionBlur must perform some cleanup tasks
					}
					if (_time / _duration > 0.998) { //if the tween has finished (or come extremely close to finishing), we just need to rewind it to 0 and then render it again at the end which forces it to re-initialize (parsing the new vars). We allow tweens that are close to finishing (but haven't quite finished) to work this way too because otherwise, the values are so small when determining where to project the starting values that binary math issues creep in and can make the tween appear to render incorrectly when run backwards. 
						var prevTime:Number = _time;
						render(0, true, false);
						_initted = false;
						render(prevTime, true, false);
					} else if (_time > 0) {
						_initted = false;
						_init();
						var inv:Number = 1 / (1 - curRatio),
							pt:Object = _firstPT, endValue:Number;
						while (pt) {
							endValue = pt.s + pt.c; 
							pt.c *= inv;
							pt.s = endValue - pt.c;
							pt = pt._next;
						}
					}
				}
			}
			return this;
		}
				
		public function render(time:Number, suppressEvents:Boolean, force:Boolean):Void {
			var totalDur:Number = (!_dirty) ? _totalDuration : totalDuration(), 
				prevTime:Number = _time,
				prevTotalTime:Number = _totalTime, 
				prevCycle:Number = _cycle, 
				isComplete:Boolean, callback:String, pt:Object;
			if (time >= totalDur) {
				_totalTime = totalDur;
				_cycle = _repeat;
				if (_yoyo && (_cycle & 1) !== 0) {
					_time = 0;
					ratio = _ease._calcEnd ? _ease.getRatio(0) : 0;
				} else {
					_time = _duration;
					ratio = _ease._calcEnd ? _ease.getRatio(1) : 1;
				}
				if (!_reversed) {
					isComplete = true;
					callback = "onComplete";
				}
				if (_duration === 0) { //zero-duration tweens are tricky because we must discern the momentum/direction of time in order to determine whether the starting values should be rendered or the ending values. If the "playhead" of its timeline goes past the zero-duration tween in the forward direction or lands directly on it, the end values should be rendered, but if the timeline's "playhead" moves past it in the backward direction (from a postitive time to a negative time), the starting values must be rendered.
					if (time === 0 || _rawPrevTime < 0) if (_rawPrevTime !== time) {
						force = true;
					}
					_rawPrevTime = time;
				}
				
			} else if (time <= 0) {
				_totalTime = _time = _cycle = 0;
				ratio = _ease._calcEnd ? _ease.getRatio(0) : 0;
				if (prevTotalTime != 0 || (_duration == 0 && _rawPrevTime > 0)) {
					callback = "onReverseComplete";
					isComplete = _reversed;
				}
				if (time < 0) {
					_active = false;
					if (_duration == 0) { //zero-duration tweens are tricky because we must discern the momentum/direction of time in order to determine whether the starting values should be rendered or the ending values. If the "playhead" of its timeline goes past the zero-duration tween in the forward direction or lands directly on it, the end values should be rendered, but if the timeline's "playhead" moves past it in the backward direction (from a postitive time to a negative time), the starting values must be rendered.
						if (_rawPrevTime >= 0) {
							force = true;
						}
						_rawPrevTime = time;
					}
				} else if (!_initted) { //if we render the very beginning (time == 0) of a fromTo(), we must force the render (normal tweens wouldn't need to render at a time of 0 when the prevTime was also 0). This is also mandatory to make sure overwriting kicks in immediately.
					force = true;
				}
			} else {
				_totalTime = _time = time;
				
				if (_repeat != 0) {
					var cycleDuration:Number = _duration + _repeatDelay;
					_cycle = (_totalTime / cycleDuration) >> 0; //originally _totalTime % cycleDuration but floating point errors caused problems, so I normalized it. (4 % 0.8 should be 0 but Flash reports it as 0.79999999!)
					if (_cycle !== 0) if (_cycle === _totalTime / cycleDuration) {
						_cycle--; //otherwise when rendered exactly at the end time, it will act as though it is repeating (at the beginning)
					}
					_time = _totalTime - (_cycle * cycleDuration);
					if (_yoyo) if ((_cycle & 1) !== 0) {
						_time = _duration - _time;
					}
					if (_time > _duration) {
						_time = _duration;
					} else if (_time < 0) {
						_time = 0;
					}
				}
				
				if (_easeType) {
					var r:Number = _time / _duration, type:Number = _easeType, pow:Number = _easePower;
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
					} else if (_time / _duration < 0.5) {
						ratio = r / 2;
					} else {
						ratio = 1 - (r / 2);
					}
					
				} else {
					ratio = _ease.getRatio(_time / _duration);
				}
				
			}
			
			if (prevTime === _time && !force) {
				if (prevTotalTime !== _totalTime) if (_onUpdate != null) if (!suppressEvents) { //so that onUpdate fires even during the repeatDelay - as long as the totalTime changed, we should trigger onUpdate.
					_onUpdate.apply(vars.onUpdateScope || this, vars.onUpdateParams);
				}
				return;
			} else if (!_initted) {
				_init();
				if (!isComplete && _time) { //_ease is initially set to defaultEase, so now that init() has run, _ease is set properly and we need to recalculate the ratio. Overall this is faster than using conditional logic earlier in the method to avoid having to set ratio twice because we only init() once but renderTime() gets called VERY frequently.
					ratio = _ease.getRatio(_time / _duration);
				}
			}
			if (!_active) if (!_paused) {
				_active = true; //so that if the user renders a tween (as opposed to the timeline rendering it), the timeline is forced to re-render and align it with the proper time/frame on the next rendering cycle. Maybe the tween already finished but the user manually re-renders it as halfway done.
			}
			if (prevTotalTime == 0) if (vars.onStart) if (_totalTime !== 0 || _duration === 0) if (!suppressEvents) {
				vars.onStart.apply(vars.onStartScope || this, vars.onStartParams);
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
			
			if (_onUpdate != null) if (!suppressEvents) {
				_onUpdate.apply(vars.onUpdateScope || this, vars.onUpdateParams);
			}
			if (_cycle != prevCycle) if (!suppressEvents) if (!_gc) if (vars.onRepeat) {
				vars.onRepeat.apply(vars.onRepeatScope || this, vars.onRepeatParams);
			}
			if (callback) if (!_gc) { //check gc because there's a chance that kill() could be called in an onUpdate
				if (isComplete) {
					if (_timeline.autoRemoveChildren) {
						_enabled(false, false);
					}
					_active = false;
				}
				if (!suppressEvents) if (vars[callback]) {
					vars[callback].apply(vars[callback + "Scope"] || this, vars[callback + "Params"]);
				}
			}
		}
		
//---- STATIC FUNCTIONS -----------------------------------------------------------------------------------------------------------
		
		public static function to(target:Object, duration:Number, vars:Object):TweenMax {
			return new TweenMax(target, duration, vars);
		}
		
		public static function from(target:Object, duration:Number, vars:Object):TweenMax {
			vars.runBackwards = true;
			if (vars.immediateRender != false) {
				vars.immediateRender = true;
			}
			return new TweenMax(target, duration, vars);
		}
		
		public static function fromTo(target:Object, duration:Number, fromVars:Object, toVars:Object):TweenMax {
			toVars.startAt = fromVars;
			if (fromVars.immediateRender) {
				toVars.immediateRender = true;
			}
			return new TweenMax(target, duration, toVars);
		}
		
		public static function staggerTo(targets:Array, duration:Number, vars:Object, stagger:Number, onCompleteAll:Function, onCompleteAllParams:Array, onCompleteAllScope:Object):Array {
			stagger = stagger || 0;
			var a:Array = [],
				l:Number = targets.length,
				delay:Number = vars.delay || 0,
				copy:Object,
				i:Number,
				p:String;
			for (i = 0; i < l; i++) {
				copy = {};
				for (p in vars) {
					copy[p] = vars[p];
				}
				copy.delay = delay;
				if (i == l - 1) if (onCompleteAll != null) {
					copy.onComplete = function():Void {
						if (vars.onComplete) {
							vars.onComplete.apply(vars.onCompleteScope || this, vars.onCompleteParams);
						}
						onCompleteAll.apply(onCompleteAllScope, onCompleteAllParams);
					}
				}
				a[i] = new TweenMax(targets[i], duration, copy);
				delay += stagger;
			}
			return a;
		}
		
		public static function staggerFrom(targets:Array, duration:Number, vars:Object, stagger:Number, onCompleteAll:Function, onCompleteAllParams:Array, onCompleteAllScope:Object):Array {
			vars.runBackwards = true;
			if (vars.immediateRender != false) {
				vars.immediateRender = true;
			}
			return staggerTo(targets, duration, vars, stagger, onCompleteAll, onCompleteAllParams, onCompleteAllScope);
		}
		
		public static function staggerFromTo(targets:Array, duration:Number, fromVars:Object, toVars:Object, stagger:Number, onCompleteAll:Function, onCompleteAllParams:Array, onCompleteAllScope:Object):Array {
			toVars.startAt = fromVars;
			if (fromVars.immediateRender) {
				toVars.immediateRender = true;
			}
			return staggerTo(targets, duration, toVars, stagger, onCompleteAll, onCompleteAllParams, onCompleteAllScope);
		}
		
		public static var allTo:Function = staggerTo;
		public static var allFrom:Function = staggerFrom;
		public static var allFromTo:Function = staggerFromTo; 
		
		public static function delayedCall(delay:Number, callback:Function, params:Array, scope:Object, useFrames:Boolean):TweenMax {
			return new TweenMax(callback, 0, {delay:delay, onComplete:callback, onCompleteParams:params, onCompleteScope:scope, onReverseComplete:callback, onReverseCompleteParams:params, onReverseCompleteScope:scope, immediateRender:false, useFrames:useFrames, overwrite:0});
		}
		
		public static function set(target:Object, vars:Object):TweenMax {
			return new TweenMax(target, 0, vars);
		}
		
		public static function isTweening(target:Object):Boolean {
			var a:Array = TweenLite.getTweensOf(target),
				i:Number = a.length,
				tween:TweenLite;
			while (--i > -1) {
				if (((tween = a[i])._active || (tween._startTime == tween.timeline._time && tween.timeline._active))) {
					return true;
				}
			}
			return false;
		}
		
		public static function getAllTweens(includeTimelines:Boolean):Array {
			var a:Array = _getChildrenOf(Animation._rootTimeline, includeTimelines);
			return a.concat( _getChildrenOf(Animation._rootFramesTimeline, includeTimelines) );
		}
		
		private static function _getChildrenOf(timeline:SimpleTimeline, includeTimelines:Boolean):Array {
			if (timeline == null) {
				return [];
			}
			var a:Array = [],
				cnt:Number = 0,
				tween:Animation = timeline._first;
			while (tween) {
				if (tween instanceof TweenLite) {
					a[cnt++] = tween;
				} else {
					if (includeTimelines) {
						a[cnt++] = tween;
					}
					a = a.concat(_getChildrenOf(SimpleTimeline(tween), includeTimelines));
					cnt = a.length;
				}
				tween = tween._next;
			}
			return a;
		}
		
		public static function killAll(complete:Boolean, tweens:Boolean, delayedCalls:Boolean, timelines:Boolean):Void {
			if (tweens == null) {
				tweens = true;
			}
			if (delayedCalls == null) {
				delayedCalls = true;
			}
			var a:Array = getAllTweens((timelines != false)),
				l:Number = a.length,
				isDC:Boolean,
				allTrue:Boolean = (tweens && delayedCalls && timelines),
				tween:Animation, i:Number;
			for (i = 0; i < l; i++) {
				tween = a[i];
				if (allTrue || (tween instanceof SimpleTimeline) || ((isDC = (TweenLite(tween).target == TweenLite(tween).vars.onComplete)) && delayedCalls) || (tweens && !isDC)) {
					if (complete) {
						tween.totalTime(Number(tween.totalDuration()));
					} else {
						tween._enabled(false, false);
					}
				}
			}
		}

		public static function killChildTweensOf(parent:MovieClip, complete:Boolean):Void {
			var a:Array = getAllTweens(false),
				curTarget:Object, curParent:MovieClip,
				l:Number = a.length,
				i:Number;
			for (i = 0; i < l; i++) {
				curTarget = a[i].target;
				if (curTarget instanceof MovieClip) {
					curParent = curTarget._parent;
					while (curParent) {
						if (curParent == parent) {
							if (complete) {
								a[i].totalTime(a[i].totalDuration());
							} else {
								a[i]._enabled(false, false);
							}
						}
						curParent = curParent._parent;
					}
				}
			}
		}
		
		public static function pauseAll(tweens:Boolean, delayedCalls:Boolean, timelines:Boolean):Void {
			_changePause(true, tweens, delayedCalls, timelines);
		}
		
		public static function resumeAll(tweens:Boolean, delayedCalls:Boolean, timelines:Boolean):Void {
			_changePause(false, tweens, delayedCalls, timelines);
		}
		
		private static function _changePause(pause:Boolean, tweens:Boolean, delayedCalls:Boolean, timelines:Boolean):Void {
			if (tweens == undefined) {
				tweens = true;
			}
			if (delayedCalls == undefined) {
				delayedCalls = true;
			}
			var a:Array = getAllTweens(timelines),
				isDC:Boolean, 
				tween:Animation,
				allTrue:Boolean = (tweens && delayedCalls && timelines),
				i:Number = a.length;
			while (--i > -1) {
				tween = a[i];
				if (allTrue || (tween instanceof SimpleTimeline) || ((isDC = (TweenLite(tween).target == TweenLite(tween).vars.onComplete)) && delayedCalls) || (tweens && !isDC)) {
					tween.paused(pause);
				}
			}
		}
		
	
//---- GETTERS / SETTERS ----------------------------------------------------------------------------------------------------------
		
		public function progress(value:Number) {
			return (!arguments.length) ? _time / duration() : totalTime( duration() * ((_yoyo && (_cycle & 1) !== 0) ? 1 - value : value) + (_cycle * (_duration + _repeatDelay)), false);
		}
		
		public function totalProgress(value:Number) {
			return (!arguments.length) ? _totalTime / totalDuration() : totalTime( totalDuration() * value, false);
		}
		
		public function time(value:Number, suppressEvents:Boolean) {
			if (!arguments.length) {
				return _time;
			}
			if (_dirty) {
				totalDuration();
			}
			if (value > _duration) {
				value = _duration;
			}
			if (_yoyo && (_cycle & 1) !== 0) {
				value = (_duration - value) + (_cycle * (_duration + _repeatDelay));
			} else if (_repeat != 0) {
				value += _cycle * (_duration + _repeatDelay);
			}
			return totalTime(value, suppressEvents);
		}
		
		public function totalDuration(value:Number) {
			if (!arguments.length) {
				if (_dirty) {
					//instead of Infinity, we use 999999999999 so that we can accommodate reverses
					_totalDuration = (_repeat === -1) ? 999999999999 : _duration * (_repeat + 1) + (_repeatDelay * _repeat);
					_dirty = false;
				}
				return _totalDuration;
			}
			return (_repeat == -1) ? this : duration( (value - (_repeat * _repeatDelay)) / (_repeat + 1) );
		}
		
		public function repeat(value:Number) {
			if (!arguments.length) {
				return _repeat;
			}
			_repeat = value;
			return _uncache(true);
		}
		
		public function repeatDelay(value:Number) {
			if (!arguments.length) {
				return _repeatDelay;
			}
			_repeatDelay = value;
			return _uncache(true);
		}
		
		public function yoyo(value:Boolean) {
			if (!arguments.length) {
				return _yoyo;
			}
			_yoyo = value;
			return this;
		}
		
		public static function globalTimeScale(value:Number):Number {
			if (!arguments.length) {
				return (_rootTimeline == null) ? 1 : _rootTimeline._timeScale;
			}
			value = value || 0.0001; //can't allow zero because it'll throw the math off
			if (_rootTimeline == null) {
				TweenLite.to({}, 0, {}); //forces initialization in case globalTimeScale is set before any tweens are created.
			}
			var tl:SimpleTimeline = _rootTimeline,
				t:Number = (getTimer() / 1000);
			tl._startTime = t - ((t - tl._startTime) * tl._timeScale / value);
			tl = _rootFramesTimeline;
			t = _rootFrame;
			tl._startTime = t - ((t - tl._startTime) * tl._timeScale / value);
			_rootFramesTimeline._timeScale = _rootTimeline._timeScale = value;
			return value;
		}
	
} tl._timeScale / value);
			tl = _rootFramesTimeline;
			t = _rootFrame;
			tl._startTime = t - ((t - tl._startTime) * tl._timeScale / value);
			_rootFramesTimeline._timeScale = _rootTimeline._timeScale = value;
			return value;
		}
	
}