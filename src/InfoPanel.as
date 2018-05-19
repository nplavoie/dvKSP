package 
{
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFieldAutoSize;
	
	/**
	 * ...
	 * @author Nicolas Philippe Lavoie
	 */
	public class InfoPanel extends Sprite
	{
		private var _stageData:Array;
		private var _titleArray:Array = ["Stage", "Total mass (t)", "Payload mass", "Mass of oxydizer (LOX)", "Mass of liquid fuel", "Mass of monopropellant", "Mass of xenon gas", "Mass of solid fuel", "Thrust force (kN) in vaccum", "Thrust force in atmosphere", "ISP vaccum (s)", "ISP atm", "Delta V (m/s) in vaccum", "Delta V in atm", "Coefficient of drag", "Area of stage section", "Planet of reference for calculation", "Thrust to weight ratio (vaccum)", "Thrust to weight ratio (atm)", "Terminal velocity at ground (m/s)" ];
		private var _textFields:Vector.<TextField>;
				
		public function InfoPanel() 
		{
			_createTextFields();
		}
		
		private function _createTextFields():void{
			var max:int = _titleArray.length;
			_textFields = new Vector.<TextField>();
			var i:int;
			var textField:TextField;
			
			textField = new TextField();
			textField.selectable = false;
			textField.embedFonts = true;
			textField.mouseEnabled = false;
			textField.defaultTextFormat = new TextFormat('arial', 13, GlobalVariables._whiteColor, true);
			textField.autoSize = TextFieldAutoSize.LEFT;
			addChild(textField);
			_textFields.push(textField);			
			
			for(i=1;i<max;i++){
				textField = new TextField();
				textField.selectable = false;
				textField.embedFonts = true;
				textField.mouseEnabled = false;
				textField.defaultTextFormat = new TextFormat('arial', 11, GlobalVariables._whiteColor);
				textField.autoSize = TextFieldAutoSize.LEFT;
				textField.y = 14 * i + 3;
				addChild(textField);
				_textFields.push(textField);
			}
		}
		
		private function _drawBackground():void{
			graphics.clear();
			// get the bounds of the _clip (_clip would be your movieClip)
			var rect:Rectangle = getBounds(this);
			var offset:Number = 3;
			
			// draw a box based on the rect
			with(this.graphics) {
				lineStyle(3,GlobalVariables._redColor,0.85);
				beginFill(0x000000, 0.85);
				moveTo(rect.x - offset, rect.y - offset);
				lineTo(rect.x + offset + rect.width, rect.y - offset);
				lineTo(rect.x + offset + rect.width, rect.y + offset + rect.height);
				lineTo(rect.x - offset, rect.y + offset + rect.height);
				lineTo(rect.x - offset, rect.y - offset);
				endFill();
			}
		}
		
		private function _updateInfoPanelData():void{
			var len:int = _textFields.length;
			for (var i:int = 0; i < len -2 ; i++) {
				_textFields[i].text = _titleArray[i] + " : " + String(_stageData[i]);
			}
			if(_stageData[1] > 0 && Constantes[_stageData[16]][7]!= null) {
				_textFields[17].text = _titleArray[17] + " : " + String(Math.round(_stageData[8] / _stageData[1] / Constantes[_stageData[16]][1] * 10) / 10);
				_textFields[18].text = _titleArray[18] + " : " + String(Math.round(_stageData[9] / _stageData[1] / Constantes[_stageData[16]][1] * 10) / 10);
				_textFields[19].text = _titleArray[19] + " : " + String(Math.round(Math.sqrt(2 * _stageData[1] * Constantes[_stageData[16]][1] / Constantes[_stageData[16]][7] / _stageData[14] /  _stageData[15]) * 10) / 10);
			}else {
				_textFields[17].text = _titleArray[17] + " : " + "0";
				_textFields[18].text = _titleArray[18] + " : " + "0";
				_textFields[19].text = _titleArray[19] + " : " + "0";
			}
		}
		
		//Setters
		public function set updateData(value:Array):void{
			_stageData = value;
			_updateInfoPanelData();
			_drawBackground()
		}
		
	}

}