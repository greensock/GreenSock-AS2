/**
 * VERSION: 3.0
 * DATE: 9/14/2009
 * AS2
 * UPDATES AND DOCUMENTATION AT: http://www.greensock.com
 **/

import com.greensock.events.Event;
/**
 * EventDispatcher mimics the event model in AS3. Just extend this class to make your AS2 class
 * able to dispatch events.
 * 
 * <b>Copyright 2014, GreenSock. All rights reserved.</b> This work is subject to the terms in <a href="http://www.greensock.com/terms_of_use.html">http://www.greensock.com/terms_of_use.html</a> or for <a href="http://www.greensock.com/club/">Club GreenSock</a> members, the software agreement that was issued with the membership.
 * 
 * @author Jack Doyle, jack@greensock.com
 */	 
class com.greensock.events.EventDispatcher {
	private var _listeners:Array;
	
	public function EventDispatcher() {
		_listeners = [];
	}
	
	public function addEventListener(type:String, listener:Function, scope:Object):Void {
		var i:Number = _listeners.length;
		while (i--) {
			if (_listeners[i].listener == listener && _listeners[i].type == type) {
				return;
			}
		}
		_listeners[_listeners.length] = {type:type, listener:listener, scope:scope};
	}
	
	public function removeEventListener(type:String, listener:Function):Void {
		var i:Number = _listeners.length;
		while (i--) {
			if (_listeners[i].listener == listener && _listeners[i].type == type) {
				_listeners.splice(i, 1);
				return;
			}
		}
	}
	
	public function dispatchEvent(event:Event):Void {
		event.target = this;
		var type:String = event.type;
		var l:Number = _listeners.length;
		for (var i:Number = 0; i < l; i++) {
			if (_listeners[i].type == type) {
				if (_listeners[i].scope) {
					_listeners[i].listener.apply(_listeners[i].scope, [event]);
				} else {
					_listeners[i].listener(event);
				}
			}
		}
	}
	
}