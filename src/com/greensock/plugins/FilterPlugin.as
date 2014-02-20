/**
 * VERSION: 12.0.1
 * DATE: 2013-05-21
 * AS2
 * UPDATES AND DOCS AT: http://www.greensock.com
 **/
import com.greensock.TweenLite;
import com.greensock.plugins.TweenPlugin;
import com.greensock.plugins.HexColorsPlugin;
import flash.filters.BitmapFilter;
import flash.filters.BlurFilter;
/**
 * <p><strong>See AS3 files for full ASDocs</strong></p>
 * 
 * <p><strong>Copyright 2008-2014, GreenSock. All rights reserved.</strong> This work is subject to the terms in <a href="http://www.greensock.com/terms_of_use.html">http://www.greensock.com/terms_of_use.html</a> or for <a href="http://www.greensock.com/club/">Club GreenSock</a> members, the software agreement that was issued with the membership.</p>
 * 
 * @author Jack Doyle, jack@greensock.com
 */
class com.greensock.plugins.FilterPlugin extends TweenPlugin {
		public static var API:Number = 2; //If the API/Framework for plugins changes in the future, this number helps determine compatibility
		private var _target:Object;
		private var _type:Object;
		private var _filter:BitmapFilter;
		private var _index:Number;
		private var _remove:Boolean;
		private var _tween:TweenLite;
		
		public function FilterPlugin(props:String, priority:Number) {
			super(props, priority);
		}
		
		private function _initFilter(target, props:Object, tween:TweenLite, type:Object, defaultFilter:BitmapFilter, propNames:Array):Boolean {
			_target = target;
			_tween = tween;
			_type = type;
			var filters:Array = _target.filters, p:String, i:Number, colorTween:HexColorsPlugin;
			var extras:Object = (props instanceof BitmapFilter) ? {} : props;
			if (extras.index != null) {
				_index = extras.index;
			} else {
				_index = filters.length;
				if (extras.addFilter != true) {
					while (--_index > -1 && !(filters[_index] instanceof _type)) { };
				}
			}
			if (_index < 0 || !(filters[_index] instanceof _type)) {
				if (_index < 0) {
					_index = filters.length;
				}
				if (_index > filters.length) { //in case the requested index is too high, pad the lower elements with BlurFilters that have a blur of 0. 
					i = filters.length - 1;
					while (++i < _index) {
						filters[i] = new BlurFilter(0, 0, 1);
					}
				}
				filters[_index] = defaultFilter;
				_target.filters = filters;
			}
			_filter = filters[_index];
			_remove = (extras.remove == true);
			i = propNames.length;
			while (--i > -1) {
				p = propNames[i];
				if (props[p] != null && _filter[p] != props[p]) {
					if (p == "color" || p == "highlightColor" || p == "shadowColor") {
						colorTween = new HexColorsPlugin();
						colorTween._initColor(_filter, p, props[p]);
						_addTween(colorTween, "setRatio", 0, 1, _propName);
					} else if (p == "quality" || p == "inner" || p == "knockout" || p == "hideObject") {
						_filter[p] = props[p];
					} else {
						_addTween(_filter, p, _filter[p], props[p], _propName);
					}
				}
			}
			return true;
		}
		
		public function setRatio(v:Number):Void {
			super.setRatio(v);
			var filters:Array = _target.filters;
			if (!(filters[_index] instanceof _type)) { //a filter may have been added or removed since the tween began, changing the index.
				_index = filters.length; //default (in case it was removed)
				while (--_index > -1 && !(filters[_index] instanceof _type)) { };
				if (_index == -1) {
					_index = filters.length;
				}
			}
			if (v == 1 && _remove && _tween._time == _tween._duration) {
				if (_index < filters.length) {
					filters.splice(_index, 1);
				}
			} else {
				filters[_index] = _filter;
			}
			_target.filters = filters;
		}
	
}