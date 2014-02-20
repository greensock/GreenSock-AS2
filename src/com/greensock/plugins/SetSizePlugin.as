/**
 * VERSION: 12.0
 * DATE: 2012-01-12
 * AS2
 * UPDATES AND DOCS AT: http://www.greensock.com
 **/
import com.greensock.TweenLite;
import com.greensock.plugins.TweenPlugin;
/**
 * <p><strong>See AS3 files for full ASDocs</strong></p>
 * 
 * <p><strong>Copyright 2008-2014, GreenSock. All rights reserved.</strong> This work is subject to the terms in <a href="http://www.greensock.com/terms_of_use.html">http://www.greensock.com/terms_of_use.html</a> or for <a href="http://www.greensock.com/club/">Club GreenSock</a> members, the software agreement that was issued with the membership.</p>
 * 
 * @author Jack Doyle, jack@greensock.com
 */
class com.greensock.plugins.SetSizePlugin extends TweenPlugin {
	public static var API:Number = 2; //If the API/Framework for plugins changes in the future, this number helps determine compatibility	
	public var width:Number;
	public var height:Number;
	private var _target:Object;
	private var _setWidth:Boolean;
	private var _setHeight:Boolean;
	private var _hasSetSize:Boolean;
		
	public function SetSizePlugin() {
		super("setSize,_width,_height,scale,_xscale,_yscale");
	}
	
	public function _onInitTween(target:Object, value:Object, tween:TweenLite):Boolean {
		if (typeof(target) != "movieclip") { return false; }
		_target = target;
		_hasSetSize = (_target.setSize != null);
		
		if ( (value.width != null ) && _target._width != value.width) {
			_addTween(this, "width", _target._width, value.width, "_width", true);
			_setWidth = _hasSetSize;
		}
		if ( (value.height != null ) && _target._height != value.height) {
			_addTween(this, "height", _target._height, value.height, "_height", true);
			_setHeight = _hasSetSize;
		}			
		return true;
	}
	
	public function _kill(lookup:Object):Boolean {
		if (lookup.width != null || lookup._width != null || lookup._xscale != null) {
			_setWidth = false;
		}
		if (lookup.height != null || lookup._height != null || lookup._yscale != null) {
			_setHeight = false;
		}
		return super._kill(lookup);
	}
	
	public function setRatio(v:Number):Void {
		super.setRatio(v);
		_target.setSize((_setWidth) ? this.width : _target._width, (_setHeight) ? this.height : _target._height);
	}
}