package 
{
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.events.MouseEvent;
	/**
	 * ...
	 * @author Nicolas Philippe Lavoie
	 */
	public class Plot2D extends Sprite
	{
		private var _width:Number, _height:Number, _offset:Number = 30, _subX:int, _subY:int;
		private var _dvX:Number, _dvY:Number;
		private var _grid:Shape, _axis:Shape, _curve:Shape, _panel:Sprite;
		private var _panelTextFields:Vector.<TextField>;
		public function Plot2D(width:Number, height:Number, subX:int, subY:int, labelArray:Array, data:Array, extraData:Array, displayArray:Array, destageArray:Array) 
		{
			var title:String = displayArray[0], Apoapsis:String = displayArray[1], Periapsis:String = displayArray[2];
			_width = width - _offset * 2, _height = height - _offset * 2;
			_subX = subX, _subY = subY;
			_drawGrid();
			var maxX:Number = GlobalFunctions.max(data[0]);
			var maxY:Number = GlobalFunctions.max(data[1]);
			_displayTitle(title, Apoapsis, Periapsis);
			_drawAxis(labelArray, maxX, maxY);
			if (data[0].length > 2) {
				_drawCurve(data);
				_createPanel();
				_drawPOI(extraData, destageArray);
			}
		}
		
		private function _getX(value:Number):Number {
			if (value > _width) value = _width;
			else if(value < 0) value = 0;
			return _offset + value;
		}
		
		private function _getY(value:Number):Number {
			if (value > _height) value = _height;
			else if(value < 0) value = 0;
			return _offset + _height - value;
		}
		
		private function _drawGrid():void {
			var dx:Number = _width / _subX;
			var dy:Number = _height / _subY;
			
			_grid = new Shape();
			addChild(_grid);
			var i:int, j:int;
			var ssubX:int, ssubY:int;
			ssubX = ssubY = 5;
			with (_grid.graphics) {
				for (i = 0; i < _subY; i++) {
					lineStyle(0.5, 0x333333);
					moveTo(_getX(0), _getY(i * dy));
					lineTo(_getX(_width), _getY(i * dy));
					for (j = 1; j < ssubY; j++ ) {
						lineStyle(0.5, 0x202020);
						moveTo(_getX(0), _getY(i * dy + j * dy / ssubY));
						lineTo(_getX(_width), _getY(i * dy + j * dy / ssubY));
					}
				}
				for (i = 0; i < _subX; i++) {
					lineStyle(0.5, 0x454545);
					moveTo(_getX(i * dx), _getY(0));
					lineTo(_getX(i * dx), _getY(_height));
					for (j = 1; j < ssubX; j++ ) {
						lineStyle(0.5, 0x202020);
						moveTo(_getX(i * dx + j * dx / ssubX), _getY(0));
						lineTo(_getX(i * dx + j * dx / ssubX), _getY(_height));
					}
				}
			}
		}
		
		private function _displayTitle(title:String, value1:String, value2:String):void {
			//title textField
			var textField:TextField = new TextField();
			textField.selectable = false;
			textField.embedFonts = true;
			textField.mouseEnabled = false;
			textField.defaultTextFormat = new TextFormat('arial', 12, GlobalVariables._whiteColor, true, null, null, null, null, TextFormatAlign.CENTER);
			textField.text = String(title) + " - Ap : " + value1 + " - Pe : " + value2;
			textField.autoSize = "left";
			textField.x = _getX(_width / 2) - textField.width / 2;
			textField.y = _getY(_height) - 0.5 * (_offset + textField.height);
			addChild(textField);
		}

		private function _drawAxis(AxisLabel:Array, mX:Number, mY:Number):void {
			var dx:Number = _width / _subX;
			var dy:Number = _height / _subY;
			
			//define nbr of pixels / value (to be used when plotting the line)
			var exp:int = Math.pow(10, Math.floor(Math.log(mX) / 2.302585093) - 1);
			if (exp < 1) exp = 1;
			var dValueX:Number = (Math.ceil(mX / exp) * exp) / _subX;
			_dvX = _width / (Math.ceil(mX / exp) * exp);
			exp = Math.pow(10, (Math.floor(Math.log(mY) / 2.302585093) - 1));
			if (exp < 1) exp = 1;
			_dvY = _height / (Math.ceil(mY / exp) * exp);
			var dValueY:Number = (Math.ceil(mY / exp) * exp) / _subY;

			var textField:TextField;
			var xDataLabels:Vector.<TextField> = new Vector.<flash.text.TextField>();
			var yDataLabels:Vector.<TextField> = new Vector.<flash.text.TextField>();
			
			_axis = new Shape();
			addChild(_axis);
			
			var i:int;
			with (_axis.graphics) {
				lineStyle(1.75, 0xBBBBBB);
				//x axis
				moveTo(_getX(0), _getY(0));
				lineTo(_getX(_width), _getY(0));
				
				for (i = 0; i <= _subX; i++) {
					moveTo(_getX(i * dx), _getY(0));
					lineTo(_getX(i * dx), _getY(5));
					//x data labels
					textField = new TextField();
					textField.selectable = false;
					textField.embedFonts = true;
					textField.mouseEnabled = false;
					textField.defaultTextFormat = new TextFormat('arial', 10, GlobalVariables._whiteColor, true, null, null, null, null, TextFormatAlign.CENTER);
					textField.text = String(Math.round(dValueX * i));
					textField.autoSize = "left";
					textField.x = _getX(i * dx) - textField.width/2;
					textField.y = _getY(0) + 1;
					addChild(textField);
					xDataLabels.push(textField);
				}
				//x label
				textField = new TextField();
				textField.selectable = false;
				textField.embedFonts = true;
				textField.mouseEnabled = false;
				textField.defaultTextFormat = new TextFormat('arial', 11, GlobalVariables._whiteColor, true, null, null, null, null, TextFormatAlign.CENTER);
				textField.text = AxisLabel[0];
				textField.autoSize = "left";
				textField.x = _getX(_width / 2);
				textField.y = _getY(0) + _offset - textField.height;
				addChild(textField);
				
				//y axis
				moveTo(_getX(0), _getY(0));
				lineTo(_getX(0), _getY(_height));
				for (i = 0; i <= _subY; i++) {
					moveTo(_getX(0), _getY(i * dy));
					lineTo(_getX(5), _getY(i * dy));
					//y data labels
					textField = new TextField();
					textField.selectable = false;
					textField.embedFonts = true;
					textField.mouseEnabled = false;
					textField.defaultTextFormat = new TextFormat('arial', 10, GlobalVariables._whiteColor, true, null, null, null, null, TextFormatAlign.LEFT);
					textField.text = String(Math.round(dValueY * i * 10) / 10);
					textField.autoSize = "left";
					textField.x = _getX(0) - textField.width - 1;
					textField.y = _getY(i * dy) - textField.height/2;
					addChild(textField);
					xDataLabels.push(textField);
				}
				//y label
				textField = new TextField();
				textField.selectable = false;
				textField.embedFonts = true;
				textField.mouseEnabled = false;
				textField.defaultTextFormat = new TextFormat('arial', 11, GlobalVariables._whiteColor, true, null, null, null, null, TextFormatAlign.LEFT);
				textField.text = AxisLabel[1];
				textField.autoSize = "left";
				textField.x = _getX(0) - _offset;
				textField.y = _getY(_height) - _offset;
				addChild(textField);
				
			}
		}
		
		private function _drawCurve(dataArray:Array):void {
			_curve = new Shape();
			addChild(_curve);
			var i:int, h:Number = dataArray[0].length / (_subX * 10), len:int = _subX * 10;
			with (_curve.graphics) {
				lineStyle(1, 0xFFFFFF);
				moveTo(_getX(dataArray[0][0] * _dvX), _getY(dataArray[1][0] * _dvY));
				for (i = 1; i < len; i++) {
					if (dataArray[0][Math.round(i * h)] == undefined) lineTo(_getX(dataArray[0][Math.round(i * h) - 1] * _dvX), _getY(dataArray[1][Math.round(i * h) - 1] * _dvY));
					else lineTo(_getX(dataArray[0][Math.round(i * h)] * _dvX), _getY(dataArray[1][Math.round(i * h)] * _dvY));
				}
				lineTo(_getX(dataArray[0][dataArray[0].length - 1] * _dvX), _getY(dataArray[1][dataArray[0].length - 1] * _dvY));
			}
		}
		
		private function _createPanel():void {
			_panel = new Sprite();
			//addChild(_panel);
			var txt:TextField;
			_panelTextFields = new Vector.<TextField>();
			
			for (var i:int = 0; i < 4; i++) {
				txt = new TextField();
				txt.selectable = false;
				if (i ==0) txt.defaultTextFormat = new TextFormat('arial', 10, GlobalVariables._whiteColor, true);
				else txt.defaultTextFormat = new TextFormat('arial', 10, GlobalVariables._whiteColor);
				txt.embedFonts = true;
				txt.x = 0;
				if (i > 0) txt.y = 2 + i * 12;
				txt.text = "Default text";
				txt.autoSize = "left";
				_panel.addChild(txt);
				_panelTextFields[i] = txt;
			}
		}
		
		private function _updatePanel(title:String, xRef:Number, yRef:Number, label:String, value:Number, units:String, label2:String = "", value2:Number = 0, units2:String = "", label3:String = "", value3:Number = 0, units3:String = ""):void {
			if(_panel.parent == null) addChild(_panel);
			_panel.graphics.clear();
			_panelTextFields[0].text = title;
			_panelTextFields[1].text = "Time (s) : " + xRef;
			_panelTextFields[2].text = "Altitude (km) : " + yRef;
			_panelTextFields[3].text = label + " (" + units + ") : " + value ;
			if (label2 != "") _panelTextFields[3].text += "\n" + label2 + " (" + units2 + ") : " + value2;
			if (label3 != "") _panelTextFields[3].text += "\n" + label3 + " (" + units3 + ") : " + value3;
			// get the bounds of the _clip (_clip would be your movieClip)
			var rect:Rectangle = _panel.getBounds(_panel);
			var offset:Number = 2;
			// draw a box based on the rect
			with (_panel.graphics) {
				lineStyle(1,0xFFFFFF,0.85);
				beginFill(0x000000, 0.85);
				moveTo(rect.x - offset, rect.y - offset);
				lineTo(rect.x + offset + rect.width, rect.y - offset);
				lineTo(rect.x + offset + rect.width, rect.y + offset + rect.height);
				lineTo(rect.x - offset, rect.y + offset + rect.height);
				lineTo(rect.x - offset, rect.y - offset);
				endFill();
			}
			
			var temp:int = _getX(xRef * _dvX) + 8;
			if (temp + rect.width > _width) temp = _offset / 2 + _width - rect.width;
			_panel.x = temp;
			temp = _getY(yRef * _dvY) + 8;
			if (temp + rect.height > _height) temp = _offset/2 + _height - rect.height;
			_panel.y = temp;
			temp = _getX(xRef * _dvX);
			if (temp > _panel.x && temp < _panel.x + rect.width) {
				temp = _getY(yRef * _dvY);
				if (temp > _panel.y && temp < _panel.y + rect.height) _panel.x = _getX(xRef * _dvX) - 8 - rect.width;
			}
		}
		
		private function _drawPOI(extraArray:Array, destageArray:Array):void {
			var i:int, len:int = extraArray.length, tempPOI:POI;
			if(len > 0) {
				for (i = 0; i < len; i++) {
					if(extraArray[i][1] > 0){
						tempPOI = new POI(extraArray[i], GlobalVariables._whiteColor, 5);
						tempPOI.x = _getX(extraArray[i][1] * _dvX), tempPOI.y = _getY(extraArray[i][2] * _dvY);
						addChild(tempPOI);
						tempPOI.addEventListener(MouseEvent.MOUSE_OVER, function(e:Event):void{_updatePanel(e.currentTarget.title, e.currentTarget.xRef, e.currentTarget.yRef, e.currentTarget.label, e.currentTarget.value, e.currentTarget.units, e.currentTarget.label2, e.currentTarget.value2, e.currentTarget.units2, e.currentTarget.label3, e.currentTarget.value3, e.currentTarget.units3)});
						tempPOI.addEventListener(MouseEvent.MOUSE_OUT, function(e:Event):void{removeChild(_panel)});
					}
				}
			}
			
			len = destageArray.length;
			if(len > 0) {
				for (i = 0; i < len; i++) {
					tempPOI = new POI(destageArray[i], GlobalVariables._redColor, 4);
					tempPOI.x = _getX(destageArray[i][1] * _dvX), tempPOI.y = _getY(destageArray[i][2] * _dvY);
					addChild(tempPOI);
					tempPOI.addEventListener(MouseEvent.MOUSE_OVER, function(e:Event):void{_updatePanel(e.currentTarget.title, e.currentTarget.xRef, e.currentTarget.yRef, e.currentTarget.label, e.currentTarget.value, e.currentTarget.units, e.currentTarget.label2, e.currentTarget.value2, e.currentTarget.units2, e.currentTarget.label3, e.currentTarget.value3, e.currentTarget.units3)});
					tempPOI.addEventListener(MouseEvent.MOUSE_OUT, function(e:Event):void{removeChild(_panel)});
				}
			}
		}
	}
}