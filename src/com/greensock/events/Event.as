/**
 * VERSION: 1.0
 * DATE: 9/14/2009
 * AS2 
 * UPDATES AND DOCUMENTATION AT: http://www.greensock.com
 **/
 
/**
 * Event object to be used by GreenSock's AS2 EventDispatcher.
 * 
 * <b>Copyright 2014, GreenSock. All rights reserved.</b> This work is subject to the terms in <a href="http://www.greensock.com/eula.html">http://www.greensock.com/eula.html</a> or for "Business Green" Club GreenSock members, the software agreement that was issued with the business membership.
 * 
 * @author Jack Doyle, jack@greensock.com
 */
class com.greensock.events.Event {
		public static var COMPLETE:String = "complete";
		
		public var target:Object;
		public var type:String;
		
		public function Event(type:String){
			this.type = type;
		}	
	
}