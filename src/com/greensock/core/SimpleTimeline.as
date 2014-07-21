/**
 * VERSION: 12.0.4
 * DATE: 2014-07-08
 * AS3 (AS2 version is also available)
 * UPDATES AND DOCS AT: http://www.greensock.com
 **/
import com.greensock.core.Animation;
/**
 * SimpleTimeline is the base class for TimelineLite and TimelineMax, providing the
 * most basic timeline functionality and it is used for the root timelines in TweenLite but is only
 * intended for internal use in the GreenSock tweening platform. It is meant to be very fast and lightweight.
 * 
 * <p><strong>See AS3 files for full ASDocs</strong></p>
 * 
 * <p><strong>Copyright 2008-2014, GreenSock. All rights reserved.</strong> This work is subject to the terms in <a href="http://www.greensock.com/terms_of_use.html">http://www.greensock.com/terms_of_use.html</a> or for <a href="http://www.greensock.com/club/">Club GreenSock</a> members, the software agreement that was issued with the membership.</p>
 * 
 * @author Jack Doyle, jack@greensock.com
 */
class com.greensock.core.SimpleTimeline extends Animation {
		public var autoRemoveChildren:Boolean; 
		public var smoothChildTiming:Boolean;
		public var _sortChildren:Boolean;
		public var _first:Animation;
		public var _last:Animation;
		
		public function SimpleTimeline(vars:Object) {
			super(0, vars);
			this.autoRemoveChildren = this.smoothChildTiming = true;
		}
		
		public function insert(tween, time) {
			return add(tween, time || 0);
		}
		
		public function add(child, position, align:String, stagger:Number) {
			child._startTime = Number(position || 0) + child._delay;
			if (child._paused) if (this != child._timeline) { //we only adjust the _pauseTime if it wasn't in this timeline already. Remember, sometimes a tween will be inserted again into the same timeline when its startTime is changed so that the tweens in the TimelineLite/Max are re-ordered properly in the linked list (so everything renders in the proper order). 
				child._pauseTime = child._startTime + ((rawTime() - child._startTime) / child._timeScale);
			}
			if (child.timeline) {
				child.timeline._remove(child, true); //removes from existing timeline so that it can be properly added to this one.
			}
			child.timeline = child._timeline = this;
			if (child._gc) {
				child._enabled(true, true);
			}
			
			var prevTween:Animation = _last;
			if (_sortChildren) {
				var st:Number = child._startTime;
				while (prevTween && prevTween._startTime > st) {
					prevTween = prevTween._prev;
				}
			}
			if (prevTween) {
				child._next = prevTween._next;
				prevTween._next = Animation(child);
			} else {
				child._next = _first;
				_first = Animation(child);
			}
			if (child._next) {
				child._next._prev = child;
			} else {
				_last = Animation(child);
			}
			child._prev = prevTween;
			
			if (_timeline) {
				_uncache(true);
			}
			
			return this;
		}
		
		public function _remove(tween, skipDisable:Boolean) {
			if (tween.timeline == this) {
				if (!skipDisable) {
					tween._enabled(false, true);
				}
				
				if (tween._prev) {
					tween._prev._next = tween._next;
				} else if (_first === tween) {
					_first = tween._next;
				}
				if (tween._next) {
					tween._next._prev = tween._prev;
				} else if (_last === tween) {
					_last = tween._prev;
				}
				tween._next = tween._prev = tween.timeline = null;
				
				if (_timeline) {
					_uncache(true);
				}
			}
			return this;
		}
		
		public function render(time:Number, suppressEvents:Boolean, force:Boolean):Void {
			var tween:Animation = _first, next:Animation;
			_totalTime = _time = _rawPrevTime = time;
			while (tween) {
				next = tween._next; //record it here because the value could change after rendering...
				if (tween._active || (time >= tween._startTime && !tween._paused)) {
					if (!tween._reversed) {
						tween.render((time - tween._startTime) * tween._timeScale, suppressEvents, force);
					} else {
						tween.render(((!tween._dirty) ? tween._totalDuration : tween.totalDuration()) - ((time - tween._startTime) * tween._timeScale), suppressEvents, force);
					}
				}
				tween = next;
			}
		}
		
		
//---- GETTERS / SETTERS ------------------------------------------------------------------------------
		
		public function rawTime():Number {
			return _totalTime;			
		}
}