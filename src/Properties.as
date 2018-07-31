package  {
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFormat;
	import flash.geom.Rectangle;
	import flash.display.Bitmap;
    import flash.display.BitmapData;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	/**
	 * ...
	 * @author Nicolas Philippe Lavoie
	 */
	public class Properties extends Sprite {
		private static var _nextId:int = 0;
		private var _isLinked:Boolean = false;
		private var _mass_f_LOX:Number = 0, _mass_f_LF:Number = 0, _mass_f_Mono:Number = 0, _mass_f_Xe:Number = 0, _mass_f_SF:Number = 0;	
		private var _payload:Number = 0;
		private var _thrust_Vac:Number = 0, _thrust_Atm:Number = 0, _thrust_Atm_2:Number = 0;
		private var _isp_Vac:Number = 0, _isp_Atm:Number = 0, _isp_Atm_2:Number = 0;
		
		protected var _num:int = _nextId++;
		protected var _bitmap:Bitmap;
		protected var _img:BitmapData;
		protected var _label:TextField;
		protected var _precision:Number = Constantes.precision;
		protected var _precision2:Number = Constantes.precision2;
		protected var _modPanel:ModPanel;
		
		public function Properties () {
			addEventListener(MouseEvent.RIGHT_MOUSE_UP, _openModPanel);
			EventManager.addEventListener('stageMouseOut', function():void{_closeModPanel()});
		}
		
		protected function _closeModPanel():void {
			GlobalVariables.modPanelOpened = false;
			GlobalVariables.activeEditedStage = -1;
			if (_modPanel.parent != null) removeChild(_modPanel);
			// Gestion du clavier
            removeEventListener(KeyboardEvent.KEY_UP, _onKeyUp);
			EventManager.dispatchEvent(new Event('modPanelClosed'));
		}
		
		protected function _openModPanel(event:Event):void {
			if (!GlobalVariables.modPanelOpened) {
				GlobalVariables.modPanelOpened = true;
				GlobalVariables.activeEditedStage = GlobalVariables.activeStage;
				if (_modPanel.parent == null) addChild(_modPanel);
				// Gestion du clavier
				addEventListener(KeyboardEvent.KEY_UP, _onKeyUp);
				EventManager.dispatchEvent(new Event('modPanelOpened'));
			}
		}
		
		protected function _onKeyUp(event:KeyboardEvent):void {
			if (event.keyCode == Keyboard.ENTER) _closeModPanel();
		}

		/**
         * GETTER AND SETTER.
         */
		
		internal function set resetId(value:int):void {
			_nextId = value;
		}
		
		internal function set isLinked(value:Boolean):void {
			_isLinked = value;
		}
		
		internal function get isLinked():Boolean {
			return _isLinked;
		}
		
		internal function set mass_f_LOX(value:Number):void {
			if (isNaN(value)) _mass_f_LOX = 0;
			else _mass_f_LOX = Math.round(value * _precision) / _precision;
		}
		
		internal function get mass_f_LOX():Number {
			return _mass_f_LOX;
		}
		
		internal function set mass_f_LF(value:Number):void {
			if (isNaN(value)) _mass_f_LF = 0;
			else _mass_f_LF = Math.round(value * _precision) / _precision;
		}
		
		internal function get mass_f_LF():Number {
			return _mass_f_LF;
		}
		
		internal function set mass_f_Mono(value:Number):void {
			if (isNaN(value)) _mass_f_Mono = 0;
			else _mass_f_Mono = Math.round(value * _precision) / _precision;
		}
		
		internal function get mass_f_Mono():Number {
			return _mass_f_Mono;
		}
		
		internal function set mass_f_Xe(value:Number):void {
			if (isNaN(value)) _mass_f_Xe = 0;
			else _mass_f_Xe = Math.round(value * _precision) / _precision;
		}
		
		internal function get mass_f_Xe():Number {
			return _mass_f_Xe;
		}
		
		internal function set mass_f_SF(value:Number):void {
			if (isNaN(value)) _mass_f_SF = 0;
			else _mass_f_SF = Math.round(value * _precision) / _precision;
		}
		
		internal function get mass_f_SF():Number {
			return _mass_f_SF;
		}
		
		internal function set payload(value:Number):void {
			if (isNaN(value)) _payload = 0;
			else _payload = Math.round(value * _precision) / _precision;
		}
		
		internal function get payload():Number {
			return _payload;
		}
		
		internal function set thrust_Vac(value:Number):void {
			if (isNaN(value)) _thrust_Vac = 0;
			else _thrust_Vac = Math.round(value * _precision2) / _precision2;
		}
		
		internal function get thrust_Vac():Number {
			return _thrust_Vac;
		}
		
		internal function set thrust_Atm(value:Number):void {
			if (isNaN(value)) _thrust_Atm = 0;
			else _thrust_Atm = Math.round(value * _precision2) / _precision2;
		}
		
		internal function get thrust_Atm():Number {
			return _thrust_Atm;
		}
		
		internal function set thrust_Atm_2(value:Number):void {
			if (isNaN(value)) _thrust_Atm_2 = 0;
			else _thrust_Atm_2 = Math.round(value * _precision2) / _precision2;
		}
		
		internal function get thrust_Atm_2():Number {
			return _thrust_Atm_2;
		}
		
		internal function set isp_Vac(value:Number):void {
			if (isNaN(value)) _isp_Vac = 0;
			else _isp_Vac = Math.round(value * _precision2) / _precision2;
		}
		
		internal function get isp_Vac():Number {
			return _isp_Vac;
		}
		
		internal function set isp_Atm(value:Number):void {
			if (isNaN(value)) _isp_Atm = 0;
			else _isp_Atm = Math.round(value * _precision2) / _precision2;
		}
		
		internal function get isp_Atm():Number {
			return _isp_Atm;
		}
		
		internal function set isp_Atm_2(value:Number):void {
			if (isNaN(value)) _isp_Atm_2 = 0;
			else _isp_Atm_2 = Math.round(value * _precision2) / _precision2;
		}
		
		internal function get isp_Atm_2():Number {
			return _isp_Atm_2;
		}
		
		internal function get label():String {
			return _label.text;
		}
		
	}
}
