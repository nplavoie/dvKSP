package  {
	import flash.geom.Matrix;
	import flash.text.TextField;
	import flash.events.MouseEvent;
	import flash.events.KeyboardEvent;
	import flash.events.Event;
	import flash.ui.Keyboard;

	/**
	 * ...
	 * @author Nicolas Philippe Lavoie
	 */
	public class Parts extends Properties {
		internal var _fuel_factor:int, _thrust_factor:int;
		internal var _quantity:int;
		private var _type:int;
		
		public function Parts(pArray:Array) {
			_type = pArray[0];
			_label = new TextField();
			_label.text = String(pArray[1]);
			_modPanel = new ModPanel(["1", "100", "100"],["0123456789.", "0123456789", "0123456789"],[6, 3, 3]);
			
			var variableArray:Array = ["_quantity", "payload", "mass_f_LOX", "mass_f_LF", "mass_f_SF", "mass_f_Mono", "mass_f_Xe", "thrust_Atm", "thrust_Atm_2", "thrust_Vac", "isp_Atm", "isp_Atm_2", "isp_Vac", "_fuel_factor", "_thrust_factor"];
			var label:String;
			var len:int = variableArray.length;
			_bitmap = new EmbedIcons['ImgParts' + _type]()
			_img = _bitmap.bitmapData;
			
			//Tous les paramètres non définis sont mis à zéro
			for (var i:int = 0 ; i < len; i++) {
				this[variableArray[i]] = pArray[i+2];
			}
			
			// Gestion de la souris
			addEventListener(MouseEvent.MOUSE_OUT, function():void{GlobalVariables.currentPart = -1});
			addEventListener(MouseEvent.MOUSE_OVER, function():void{GlobalVariables.currentPart = _num; GlobalVariables.currentPartType = _type; Log.setText = "Current part [" + _label.text + "]   id :  " + String(_num) + "   qty : " + String(_quantity) + "   %fuel_factor : " + String(_fuel_factor) + "   %thrust_factor : " + String(_thrust_factor) + "   payload : " + String(payload) + " - Middle Mouse to delete part - Right Mouse to modify part"  , EventManager.dispatchEvent(new Event('updateLog')); });
			
			_draw();
		}
		
		//PRIVATE related functions
		private function _draw():void {
			var mat:Matrix = new Matrix(), scaleFactor:Number = 0.6;
			mat.scale(scaleFactor,scaleFactor);
			this.graphics.beginBitmapFill(_img,mat,false,true);
			this.graphics.drawRect(0, 0, _bitmap.width*scaleFactor, _bitmap.height*scaleFactor);
			this.graphics.endFill();
		}
		
		override protected function _closeModPanel():void {
			var array:Array = _modPanel.getModifiedData;
			//Tranfert des textfields vers les données internes
			if (_type == 1) payload = array[0];
			else  _quantity = Math.round(array[0]);
			if (array[1] > 100) _fuel_factor = 100;
			else _fuel_factor = array[1];
			if (array[2] > 100) _thrust_factor = 100;
			else _thrust_factor = array[2];
			super._closeModPanel();
		}
		
		//EVENTs related functions
		override protected function _openModPanel(event:Event):void {
			if (!GlobalVariables.linkMode) {
				Log.setText = "Edit Part (top to bottom) : quantity or payload mass (t), fuel in tank (%), thrust for engine (%) - ", EventManager.dispatchEvent(new Event('updateLog'));
				super._openModPanel(event);
			}
		}

		override protected function _onKeyUp(event:KeyboardEvent):void {
			Log.setText = "Text input (top to bottom) : quantity or payload mass (t), fuel in tank (%), thrust for engine (%) - Press Enter to accept - ", EventManager.dispatchEvent(new Event('updateLog'));
			super._onKeyUp(event);
		}
		
		//GETTERS AND SETTERS related functions
		internal function set setNum(value:int):void {
			_num = value;
		}
		
		internal function get getNum():int {
			return int(_num);
		}
		
		internal function get type():int {
			return int(_type);
		}
	}
}
