/**
 * VERSION: 12.1.5
 * DATE: 2014-07-19
 * AS2 (AS3 version is also available)
 * UPDATES AND DOCS AT: http://www.greensock.com/timelinemax/
 **/
import com.greensock.TweenLite;
import com.greensock.TimelineLite;
import com.greensock.core.Animation;
import com.greensock.core.SimpleTimeline;
import com.greensock.easing.Ease;
/**
 * 	TimelineMax extends TimelineLite, offering exactly the same functionality plus useful 
 *  (but non-essential) features like repeat, repeatDelay, yoyo, 
 *  currentLabel, addCallback(), removeCallback(), tweenTo(), getLabelAfter(), getLabelBefore(),
 * 	and getActive() (and probably more in the future). 
 * 
 * <p><strong>See AS3 files for full ASDocs</strong></p>
 * 
 * <p><strong>Copyright 2008-2014, GreenSock. All rights reserved.</strong> This work is subject to the terms in <a href="http://www.greensock.com/terms_of_use.html">http://www.greensock.com/terms_of_use.html</a> or for <a href="http://www.greensock.com/club/">Club GreenSock</a> members, the software agreement that was issued with the membership.</p>
 * 
 * @author Jack Doyle, jack@greensock.com
 */
class com.greensock.TimelineMax extends TimelineLite {
		public static var version:String = "12.1.5";
		private static var _easeNone:Ease = new Ease(null, null, 1, 0);
		private var _repeat:Number;
		private var _repeatDelay:Number;
		private var _cycle:Number;
		private var _locked:Boolean;
		private var _yoyo:Boolean;
		
		public function TimelineMax(vars:Object) {
			super(vars);
			_repeat = this.vars.repeat || 0;
			_repeatDelay = this.vars.repeatDelay || 0;
			_cycle = 0;
			_yoyo = (this.vars.yoyo == true);
			_dirty = true;
		}
		
		public function invalidate() {
			_yoyo = Boolean(this.vars.yoyo == true);
			_repeat = this.vars.repeat || 0;
			_repeatDelay = this.vars.repeatDelay || 0;
			_uncache(true);
			return super.invalidate();
		}
		
		public function addCallback(callback:Function, position, params:Array, scope:Object):TimelineMax {
			return TimelineMax( add( TweenLite.delayedCall(0, callback, params, scope), position) );
		}
		
		public function removeCallback(callback:Function, position):TimelineMax {
			if (callback != null) {
				if (position == null) {
					_kill(null, callback);
				} else {
					var a:Array = getTweensOf(callback, false),
						i:Number = a.length,
						time:Number = _parseTimeOrLabel(position);
					while (--i > -1) {
						if (a[i]._startTime === time) {
							a[i]._enabled(false, false);
						}
					}
				}
			}
			return this;
		}
		
		public function tweenTo(position, vars:Object):TweenLite {
			vars = vars || {};
			var copy:Object = {ease:_easeNone, overwrite:2, useFrames:usesFrames(), immediateRender:false};
			for (var p:String in vars) {
				copy[p] = vars[p];
			}
			copy.time = _parseTimeOrLabel(position);
			var duration:Number = (Math.abs(Number(copy.time) - _time) / _timeScale) || 0.001;
			var t:TweenLite = new TweenLite(this, duration, copy);
			copy.onStart = function():Void {
				t.target.paused(true);
				if (t.vars.time != t.target.time() && duration === t.duration()) { //don't make the duration zero - if it's supposed to be zero, don't worry because it's already initting the tween and will complete immediately, effectively making the duration zero anyway. If we make duration zero, the tween won't run at all.
					t.duration( Math.abs( t.vars.time - t.target.time()) / t.target._timeScale );
				}
				if (vars.onStart) { //in case the user had an onStart in the vars - we don't want to overwrite it.
					vars.onStart.apply(vars.onStartScope || t, vars.onStartParams);
				}
			}
			return t;
		}
		
		public function tweenFromTo(fromPosition, toPosition, vars:Object):TweenLite {
			vars = vars || {};
			fromPosition = _parseTimeOrLabel(fromPosition);
			vars.startAt = {onComplete:seek, onCompleteParams:[fromPosition]};
			vars.immediateRender = (vars.immediateRender !== false);
			var t:TweenLite = tweenTo(toPosition, vars);
			return t.duration((Math.abs( t.vars.time - fromPosition) / _timeScale) || 0.001);
		}
		
		public function render(time:Number, suppressEvents:Boolean, force:Boolean):Void {
			if (_gc) {
				_enabled(true, false);
			}
			var totalDur:Number = (!_dirty) ? _totalDuration : totalDuration(), 
				prevTime:Number = _time, 
				prevTotalTime:Number = _totalTime, 
				prevStart:Number = _startTime, 
				prevTimeScale:Number = _timeScale, 
				prevRawPrevTime:Number = _rawPrevTime,
				prevPaused:Boolean = _paused, 
				prevCycle:Number = _cycle, 
				tween:Animation, isComplete:Boolean, next:Animation, dur:Number, callback:String, internalForce:Boolean;
			if (time >= totalDur) {
				if (!_locked) {
					_totalTime = totalDur;
					_cycle = _repeat;
				}
				if (!_reversed) if (!_hasPausedChild()) {
					isComplete = true;
					callback = "onComplete";
					if (_duration === 0) if (time === 0 || _rawPrevTime < 0 || _rawPrevTime === _tinyNum) if (_rawPrevTime !== time && _first) {
						internalForce = true;
						if (_rawPrevTime > _tinyNum) {
							callback = "onReverseComplete";
						}
					}
				}
				_rawPrevTime = (_duration || !suppressEvents || time !== 0 || _rawPrevTime === time) ? time : _tinyNum; //when the playhead arrives at EXACTLY time 0 (right on top) of a zero-duration timeline or tween, we need to discern if events are suppressed so that when the playhead moves again (next time), it'll trigger the callback. If events are NOT suppressed, obviously the callback would be triggered in this render. Basically, the callback should fire either when the playhead ARRIVES or LEAVES this exact spot, not both. Imagine doing a timeline.seek(0) and there's a callback that sits at 0. Since events are suppressed on that seek() by default, nothing will fire, but when the playhead moves off of that position, the callback should fire. This behavior is what people intuitively expect. We set the _rawPrevTime to be a precise tiny number to indicate this scenario rather than using another property/variable which would increase memory usage. This technique is less readable, but more efficient.
				if (_yoyo && (_cycle & 1) != 0) {
					_time = time = 0;
				} else {
					_time = _duration;
					time = _duration + 0.0001; //to avoid occasional floating point rounding errors in Flash - sometimes child tweens/timelines were not being fully completed (their progress might be 0.999999999999998 instead of 1 because when Flash performed _time - tween._startTime, floating point errors would return a value that was SLIGHTLY off)
				}
				
			} else if (time < 0.0000001) { //to work around occasional floating point math artifacts, round super small values to 0. 
				if (!_locked) {
					_totalTime = _cycle = 0;
				}
				_time = 0;
				if (prevTime !== 0 || (_duration === 0 && _rawPrevTime !== _tinyNum && (_rawPrevTime > 0 || (time < 0 && _rawPrevTime >= 0)) && !_locked)) {
					callback = "onReverseComplete";
					isComplete = _reversed;
				}
				if (time < 0) {
					_active = false;
					if (_rawPrevTime >= 0 && _first) { //zero-duration timelines are tricky because we must discern the momentum/direction of time in order to determine whether the starting values should be rendered or the ending values. If the "playhead" of its timeline goes past the zero-duration tween in the forward direction or lands directly on it, the end values should be rendered, but if the timeline's "playhead" moves past it in the backward direction (from a postitive time to a negative time), the starting values must be rendered.
						internalForce = true;
					}
					_rawPrevTime = time;
				} else {
					_rawPrevTime = (_duration || !suppressEvents || time !== 0 || _rawPrevTime === time) ? time : _tinyNum; //when the playhead arrives at EXACTLY time 0 (right on top) of a zero-duration timeline or tween, we need to discern if events are suppressed so that when the playhead moves again (next time), it'll trigger the callback. If events are NOT suppressed, obviously the callback would be triggered in this render. Basically, the callback should fire either when the playhead ARRIVES or LEAVES this exact spot, not both. Imagine doing a timeline.seek(0) and there's a callback that sits at 0. Since events are suppressed on that seek() by default, nothing will fire, but when the playhead moves off of that position, the callback should fire. This behavior is what people intuitively expect. We set the _rawPrevTime to be a precise tiny number to indicate this scenario rather than using another property/variable which would increase memory usage. This technique is less readable, but more efficient.
					time = 0;
					if (!_initted) {
						internalForce = true;
					}
				}
				
			} else {
				if (_duration === 0 && _rawPrevTime < 0) { //without this, zero-duration repeating timelines (like with a simple callback nested at the very beginning and a repeatDelay) wouldn't render the first time through.
					internalForce = true;
				}
				_time = _rawPrevTime = time;
				if (!_locked) {
					_totalTime = time;
					if (_repeat != 0) {
						var cycleDuration:Number = _duration + _repeatDelay;
						_cycle = (_totalTime / cycleDuration) >> 0; //originally _totalTime % cycleDuration but floating point errors caused problems, so I normalized it. (4 % 0.8 should be 0 but Flash reports it as 0.79999999!)
						if (_cycle !== 0) if (_cycle === _totalTime / cycleDuration) {
							_cycle--; //otherwise when rendered exactly at the end time, it will act as though it is repeating (at the beginning)
						}
						_time = _totalTime - (_cycle * cycleDuration);
						if (_yoyo) if ((_cycle & 1) != 0) {
							_time = _duration - _time;
						}
						if (_time > _duration) {
							_time = _duration;
							time = _duration + 0.0001; //to avoid occasional floating point rounding errors in Flash - sometimes child tweens/timelines were not being fully completed (their progress might be 0.999999999999998 instead of 1 because when Flash performed _time - tween._startTime, floating point errors would return a value that was SLIGHTLY off)
						} else if (_time < 0) {
							_time = time = 0;
						} else {
							time = _time;
						}
					}
				}
			}
			
			if (_cycle != prevCycle) if (!_locked) {
				/*
				make sure children at the end/beginning of the timeline are rendered properly. If, for example, 
				a 3-second long timeline rendered at 2.9 seconds previously, and now renders at 3.2 seconds (which
				would get transated to 2.8 seconds if the timeline yoyos or 0.2 seconds if it just repeats), there
				could be a callback or a short tween that's at 2.95 or 3 seconds in which wouldn't render. So 
				we need to push the timeline to the end (and/or beginning depending on its yoyo value). Also we must
				ensure that zero-duration tweens at the very beginning or end of the TimelineMax work. 
				*/
				var backwards:Boolean = (_yoyo && (prevCycle & 1) !== 0),
					wrap:Boolean = (backwards === (_yoyo && (_cycle & 1) !== 0)),
					recTotalTime:Number = _totalTime,
					recCycle:Number = _cycle,
					recRawPrevTime:Number = _rawPrevTime,
					recTime:Number = _time;
				
				_totalTime = prevCycle * _duration;
				if (_cycle < prevCycle) {
					backwards = !backwards;
				} else {
					_totalTime += _duration;
				}
				_time = prevTime; //temporarily revert _time so that render() renders the children in the correct order. Without this, tweens won't rewind correctly. We could arhictect things in a "cleaner" way by splitting out the rendering queue into a separate method but for performance reasons, we kept it all inside this method.
				
				_rawPrevTime = prevRawPrevTime;
				_cycle = prevCycle;
				_locked = true; //prevents changes to totalTime and skips repeat/yoyo behavior when we recursively call render()
				prevTime = (backwards) ? 0 : _duration;	
				render(prevTime, suppressEvents, false);
				if (!suppressEvents) if (!_gc) {
					if (vars.onRepeat) {
						vars.onRepeat.apply(null, vars.onRepeatParams);
					}
				}
				if (wrap) {
					prevTime = (backwards) ? _duration + 0.0001 : -0.0001;
					render(prevTime, true, false);
				}
				_locked = false;
				if (_paused && !prevPaused) { //if the render() triggered callback that paused this timeline, we should abort (very rare, but possible)
					return;
				}
				_time = recTime;
				_totalTime = recTotalTime;
				_cycle = recCycle;
				_rawPrevTime = recRawPrevTime;
			}

			if ((_time === prevTime || !_first) && !force && !internalForce) {
				if (prevTotalTime !== _totalTime) if (_onUpdate != null) if (!suppressEvents) { //so that onUpdate fires even during the repeatDelay - as long as the totalTime changed, we should trigger onUpdate.
					_onUpdate.apply(vars.onUpdateScope || this, vars.onUpdateParams);
				}
				return;
			} else if (!_initted) {
				_initted = true;
			}
			
			if (!_active) if (!_paused && _totalTime !== prevTotalTime && time > 0) {
				_active = true;  //so that if the user renders the timeline (as opposed to the parent timeline rendering it), it is forced to re-render and align it with the proper time/frame on the next rendering cycle. Maybe the timeline already finished but the user manually re-renders it as halfway done, for example.
			}
			
			if (prevTotalTime === 0) if (vars.onStart) if (_totalTime !== 0) if (!suppressEvents) {
				vars.onStart.apply(vars.onStartScope || this, vars.onStartParams);
			}
			
			if (_time >= prevTime) {
				tween = _first;
				while (tween) {
					next = tween._next; //record it here because the value could change after rendering...
					if (_paused && !prevPaused) { //in case a tween pauses the timeline when rendering
						break;
					} else if (tween._active || (tween._startTime <= _time && !tween._paused && !tween._gc)) {
						
						if (!tween._reversed) {
							tween.render((time - tween._startTime) * tween._timeScale, suppressEvents, force);
						} else {
							tween.render(((!tween._dirty) ? tween._totalDuration : tween.totalDuration()) - ((time - tween._startTime) * tween._timeScale), suppressEvents, force);
						}
						
					}
					tween = next;
				}
			} else {
				tween = _last;
				while (tween) {
					next = tween._prev; //record it here because the value could change after rendering...
					if (_paused && !prevPaused) { //in case a tween pauses the timeline when rendering
						break;
					} else if (tween._active || (tween._startTime <= prevTime && !tween._paused && !tween._gc)) {
						
						if (!tween._reversed) {
							tween.render((time - tween._startTime) * tween._timeScale, suppressEvents, force);
						} else {
							tween.render(((!tween._dirty) ? tween._totalDuration : tween.totalDuration()) - ((time - tween._startTime) * tween._timeScale), suppressEvents, force);
						}
						
					}
					tween = next;
				}
			}
			
			if (_onUpdate != null) if (!suppressEvents) {
				_onUpdate.apply(vars.onUpdateScope || this, vars.onUpdateParams);
			}
			
			if (callback) if (!_locked) if (!_gc) if (prevStart === _startTime || prevTimeScale != _timeScale) if (_time === 0 || totalDur >= totalDuration()) { //if one of the tweens that was rendered altered this timeline's startTime (like if an onComplete reversed the timeline), it probably isn't complete. If it is, don't worry, because whatever call altered the startTime would complete if it was necessary at the new time. The only exception is the timeScale property. Also check _gc because there's a chance that kill() could be called in an onUpdate
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
		
		public function getActive(nested:Boolean, tweens:Boolean, timelines:Boolean):Array {
			if (nested == null) {
				nested = true;
			}
			if (tweens == null) {
				tweens = true;
			}
			if (timelines == null) {
				timelines = false;
			}
			var a:Array = [], 
				all:Array = getChildren(nested, tweens, timelines), 
				cnt:Number = 0, 
				l:Number = all.length,
				i:Number, tween:Animation;
			for (i = 0; i < l; i++) {
				tween = all[i];
				//note: we cannot just check tween.active because timelines that contain paused children will continue to have "active" set to true even after the playhead passes their end point (technically a timeline can only be considered complete after all of its children have completed too, but paused tweens are...well...just waiting and until they're unpaused we don't know where their end point will be).
				if (!tween._paused) if (tween._timeline._time >= tween._startTime) if (tween._timeline._time < tween._startTime + tween._totalDuration / tween._timeScale) if (!_getGlobalPaused(tween._timeline)) {
					a[cnt++] = tween;
				}
			}
			return a;
		}
		
		private static function _getGlobalPaused(tween:Animation):Boolean {
			while (tween) {
				if (tween._paused) {
					return true;
				}
				tween = tween._timeline;
			}
			return false;
		}
		
		public function getLabelAfter(time:Number):String {
			if (!time) if (time !== 0) { //faster than isNan()
				time = _time;
			}
			var labels:Array = getLabelsArray(),
				l:Number = labels.length,
				i:Number;
			for (i = 0; i < l; i++) {
				if (labels[i].time > time) {
					return labels[i].name;
				}
			}
			return null;
		}
		
		public function getLabelBefore(time:Number):String {
			if (time == null) {
				time = _time;
			}
			var labels:Array = getLabelsArray(),
				i:Number = labels.length;
			while (--i > -1) {
				if (labels[i].time < time) {
					return labels[i].name;
				}
			}
			return null;
		}
		
		public function getLabelsArray():Array {
			var a:Array = [],
				cnt:Number = 0;
			for (var p:String in _labels) {
				a[cnt++] = {time:_labels[p], name:p};
			}
			a.sortOn("time", Array.NUMERIC);
			return a;
		}
		
		
//---- GETTERS / SETTERS -------------------------------------------------------------------------------------------------------
		
		public function progress(value:Number, suppressEvents:Boolean) {
			return (!arguments.length) ? _time / duration() : totalTime( duration() * ((_yoyo && (_cycle & 1) !== 0) ? 1 - value : value) + (_cycle * (_duration + _repeatDelay)), suppressEvents);
		}
		
		public function totalProgress(value:Number, suppressEvents:Boolean) {
			return (!arguments.length) ? _totalTime / totalDuration() : totalTime( totalDuration() * value, suppressEvents);
		}
		
		public function totalDuration(value:Number) {
			if (!arguments.length) {
				if (_dirty) {
					super.totalDuration(); //just forces refresh
					//Instead of Infinity, we use 999999999999 so that we can accommodate reverses.
					_totalDuration = (_repeat == -1) ? 999999999999 : _duration * (_repeat + 1) + (_repeatDelay * _repeat);
				}
				return _totalDuration;
			}
			return (_repeat == -1) ? this : duration( (value - (_repeat * _repeatDelay)) / (_repeat + 1) );
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
		
		public function currentLabel(value:String) {
			if (!arguments.length) {
				return getLabelBefore(_time + 0.00000001);
			}
			return seek(value, true);
		}
	
}