/**
 * VERSION: 1.0
 * DATE: 2012-07-17
 * AS2
 * UPDATES AND DOCS AT: http://www.greensock.com
 **/
/**
 * <p><strong>See AS3 files for full ASDocs</strong></p>
 * 
 * <p><strong>Copyright 2008-2014, GreenSock. All rights reserved.</strong> This work is subject to the terms in <a href="http://www.greensock.com/terms_of_use.html">http://www.greensock.com/terms_of_use.html</a> or for <a href="http://www.greensock.com/club/">Club GreenSock</a> members, the software agreement that was issued with the membership.</p>
 * 
 * @author Jack Doyle, jack@greensock.com
 */
class com.greensock.plugins.core.Segment {
		public var a:Number;
		public var b:Number;
		public var c:Number;
		public var d:Number;
		public var da:Number;
		public var ca:Number;
		public var ba:Number;
		
		public function Segment(a:Number, b:Number, c:Number, d:Number) {
			this.a = a;
			this.b = b;
			this.c = c;
			this.d = d;
			this.da = d - a;
			this.ca = c - a;
			this.ba = b - a;
		}
}