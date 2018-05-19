package  
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.net.registerClassAlias;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	import flash.utils.ByteArray;
	import flash.events.MouseEvent;
	
	/**
	 * ...
	 * @author Nicolas Philippe Lavoie
	 */
    public class Ui extends Sprite 
    {
		private var _ldr:FileReference;
		private var _log:Log;
		private var _saveIcon:Sprite, _loadIcon:Sprite, _applyAllIcon:Sprite, _simIcon:Sprite;
		internal var _map:StageMap, _simMap:SimulationMap;
		private var _inputTextFields:Vector.<TextField> = new Vector.<TextField>();
		public function Ui()
        {
			registerClassAlias("Vector.<Array>", Vector.<Array> as Class);
			//log global
			_log = new Log();
			addChild(_log);
			Log.setText = "Ui Class loaded - ", EventManager.dispatchEvent(new Event('updateLog'));
			
			_map = new StageMap();
			addChild(_map);
			
			_simMap = new SimulationMap();
			_simMap.x = 235;
			_simMap.y = 305;
			addChild(_simMap);
			
			_insertTextField();
			_drawIcons();
		}
		
		//PRIVATEs related functions
		private function _insertTextField():void {
			var legendTextFields:Vector.<TextField> = new Vector.<flash.text.TextField>();
			var textField:TextField;
			var textArray:Array = ["Input inital altitude (m)", "Inital radial velocity (m/s)", "Inital tangent velocity", "Inital rocket angle (deg)", "End rocket angle", "Begin gravity turn alt. (km)" , "End gravity turn altitude", "Safe distance to atm. (km)", "Shift burn time (%)"];
			for (var i:int = 0; i < textArray.length; i++) {
				textField = new TextField();
				textField.selectable = false;
				textField.embedFonts = true;
				textField.mouseEnabled = false;
				textField.defaultTextFormat = new TextFormat('arial', 11, GlobalVariables._defaultColor, true, null, null, null, null, TextFormatAlign.RIGHT);
				textField.width = 155;
				textField.height = 18;
				textField.x = 25;
				textField.y = 530 + i * 20;
				textField.border = true;
				textField.borderColor = 0x000000;
				textField.text = textArray[i];
				addChild(textField);
				legendTextFields.push(textField);
			}
			textArray = ["75", "0", Math.round(Constantes.kerbin[4]), "0", "90", "2.5", "70", "10", "16.5"];
			var retrictArray:Array = ["0-9.", "0-9.\\-", "0-9.\\-", "0-9.\\-", "0-9.\\-", "0-9.", "0-9.", "0-9.", "0-9.\\-"];
			for (i = 0; i < textArray.length; i++) {
				textField = new TextField();
				textField.selectable = true;
				textField.maxChars = 4;
				textField.defaultTextFormat = new TextFormat('arial', 11, GlobalVariables._defaultColor, true, null, null, null, null, TextFormatAlign.RIGHT);
				textField.embedFonts = true;
				textField.type = "input";
				textField.width = 30;
				textField.height = 18;
				textField.x = 180;
				textField.y = 530 + i * 20;
				textField.restrict = retrictArray[i];
				textField.border = true;
				textField.borderColor = 0x000000;
				textField.text = textArray[i];
				addChild(textField);
				_inputTextFields.push(textField);
			}
			_inputTextFields[0].addEventListener(MouseEvent.MOUSE_OVER, function():void{Log.setText = "The value pre-entered is the mean starting altitude from the VAB launch pad - "; EventManager.dispatchEvent(new Event('updateLog')); });
			_inputTextFields[2].addEventListener(MouseEvent.MOUSE_OVER, function():void{Log.setText = "The value pre-entered is Kerbin sideral rotational speed in m/s - please modify accordingly to the referenced planet - if positive : clockwise direction - "; EventManager.dispatchEvent(new Event('updateLog')); });
			_inputTextFields[3].addEventListener(MouseEvent.MOUSE_OVER, function():void{Log.setText = "A 0 degree angle indicates a ship pointing in the radial direction - "; EventManager.dispatchEvent(new Event('updateLog')); });
			_inputTextFields[4].addEventListener(MouseEvent.MOUSE_OVER, function():void{Log.setText = "A 90 degree angle indicates a ship pointing in the tangential (clockwise) direction - "; EventManager.dispatchEvent(new Event('updateLog')); });
			_inputTextFields[5].addEventListener(MouseEvent.MOUSE_OVER, function():void{Log.setText = "The simulated gravity turn is linear from starting altitude to end altitude - "; EventManager.dispatchEvent(new Event('updateLog')); });
			_inputTextFields[6].addEventListener(MouseEvent.MOUSE_OVER, function():void{Log.setText = "The simulated gravity turn is linear from starting altitude to end altitude - "; EventManager.dispatchEvent(new Event('updateLog')); });
			_inputTextFields[7].addEventListener(MouseEvent.MOUSE_OVER, function():void{Log.setText = "The mininal desired distance for the orbit relative to the atmospheric limit - "; EventManager.dispatchEvent(new Event('updateLog')); });
			_inputTextFields[8].addEventListener(MouseEvent.MOUSE_OVER, function():void{Log.setText = "If % is positive then the burn time will be earlier by this value: % * (Initial start of Burn vs Ap) - "; EventManager.dispatchEvent(new Event('updateLog')); });
		}
		private function _drawIcons():void{
			_saveIcon = new Sprite();
			_loadIcon = new Sprite();
			_applyAllIcon = new Sprite();
			_simIcon = new Sprite();
			
			var mat:Matrix = new Matrix();
			var scaleFactor:Number = 0.45;
			mat.scale(scaleFactor, scaleFactor);
			
			addChild(_saveIcon);
			addChild(_loadIcon);
			addChild(_applyAllIcon);
			addChild(_simIcon);
			
			_saveIcon.addEventListener(MouseEvent.MOUSE_OVER, function():void{Log.setText = "Save all stages information to a local file - "; EventManager.dispatchEvent(new Event('updateLog')); });
			_saveIcon.addEventListener(MouseEvent.MOUSE_UP, function():void{save(); exitLinkMode(); });
			_loadIcon.addEventListener(MouseEvent.MOUSE_OVER, function():void{Log.setText = "Open a local saved file - "; EventManager.dispatchEvent(new Event('updateLog')); });
			_loadIcon.addEventListener(MouseEvent.MOUSE_UP, function():void{openFile(); exitLinkMode(); });
			_applyAllIcon.addEventListener(MouseEvent.MOUSE_OVER, function():void{Log.setText = "Apply all the parts information into all stages - "; EventManager.dispatchEvent(new Event('updateLog')); });
			_applyAllIcon.addEventListener(MouseEvent.MOUSE_UP, function():void{_map._updateAllStagesData4Info(); });
			_simIcon.addEventListener(MouseEvent.MOUSE_OVER, function():void{Log.setText = "Launch the ascent simulation from the inital values entered in the input textfields bottom left - "; EventManager.dispatchEvent(new Event('updateLog')); });
			_simIcon.addEventListener(MouseEvent.MOUSE_UP, function():void{_simMap.startSimulation(_map.getData2Save, Number(_inputTextFields[0].text), Number(_inputTextFields[1].text), Number(_inputTextFields[2].text), Number(_inputTextFields[3].text), Number(_inputTextFields[4].text), Number(_inputTextFields[5].text), Number(_inputTextFields[6].text), Number(_inputTextFields[7].text), Number(_inputTextFields[8].text))});
			
			var bmap:Bitmap = new EmbedIcons.ImgSave(); 
			var bmdata:BitmapData = bmap.bitmapData;
			with(_saveIcon.graphics){
				beginBitmapFill(bmdata,mat,false,true);
				drawRect(0, 0, bmap.width*scaleFactor, bmap.height*scaleFactor);
				graphics.endFill();
			}
			
			bmap = new EmbedIcons.ImgLoad(); 
			bmdata = bmap.bitmapData;
			with(_loadIcon.graphics){
				beginBitmapFill(bmdata,mat,false,true);
				drawRect(0, 0, bmap.width*scaleFactor, bmap.height*scaleFactor);
				graphics.endFill();
			}
			
			bmap = new EmbedIcons.ImgApplyAll(); 
			bmdata = bmap.bitmapData;
			with(_applyAllIcon.graphics){
				beginBitmapFill(bmdata,mat,false,true);
				drawRect(0, 0, bmap.width*scaleFactor, bmap.height*scaleFactor);
				graphics.endFill();
			}
			
			bmap = new EmbedIcons.ImgSim(); 
			bmdata = bmap.bitmapData;
			with(_simIcon.graphics){
				beginBitmapFill(bmdata,mat,false,true);
				drawRect(0, 0, bmap.width*scaleFactor, bmap.height*scaleFactor);
				graphics.endFill();
			}
			
			_saveIcon.x = 10;
			_saveIcon.y = 170;
			_loadIcon.x = 35;
			_loadIcon.y = 170;
			_applyAllIcon.x = 60;
			_applyAllIcon.y = 170;
			_simIcon.x = 85;
			_simIcon.y = 170;
		}
		
		//INTERNALs related functions
		internal function exitLinkMode():void {
			_map.exitLinkMode();
		}
		
		internal function save():void {
			var bytes:ByteArray = new ByteArray(), object:Object = _map.getData2Save;
			var textFields:Array = [_inputTextFields[0].text, _inputTextFields[1].text, _inputTextFields[2].text, _inputTextFields[3].text , _inputTextFields[4].text, _inputTextFields[5].text, _inputTextFields[6].text, _inputTextFields[7].text, _inputTextFields[8].text];
			var index:String;
			bytes.writeObject(object);
			bytes.writeObject(textFields);
			bytes.compress();
			new FileReference().save(bytes, "Stages.dat");
		}
		
		internal function openFile():void
		{
			_ldr = new FileReference();
			_ldr.addEventListener(Event.SELECT, _onFileSelect, false, 0, true);
            _ldr.browse([new FileFilter("DAT Documents", "*.dat")]);
		}
		
		//EVENTs related functions
		
		private function _onFileSelect(event:Event):void {
			_ldr.removeEventListener(Event.SELECT, _onFileSelect);
			_ldr.addEventListener(Event.COMPLETE, _onFileLoadComplete, false, 0, true);
			_ldr.load();
		}
		
		private function _onFileLoadComplete(event:Event):void {
			var object:Object;
			var textFields:Array;
			_ldr.removeEventListener(Event.COMPLETE, _onFileLoadComplete);
			var data:* = FileReference(event.target).data;
			if (data is ByteArray)
			{
				try
				{
					ByteArray(data).uncompress();
				}
				catch(e:Error)
				{
				}
				object = data.readObject();
				textFields = data.readObject();
				_inputTextFields[0].text = textFields[0], _inputTextFields[1].text = textFields[1], _inputTextFields[2].text = textFields[2], _inputTextFields[3].text = textFields[3], _inputTextFields[4].text = textFields[4], _inputTextFields[5].text = textFields[5], _inputTextFields[6].text = textFields[6],  _inputTextFields[7].text = textFields[7], _inputTextFields[8].text = textFields[8];
			}
			_map.setLoadedData = object;
		}
    }
}