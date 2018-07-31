package  {
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFormat;
	import flash.geom.Matrix;
	import flash.filters.ColorMatrixFilter;
    import flash.events.MouseEvent;
	import flash.events.KeyboardEvent;
	import flash.events.Event;
	import flash.ui.Keyboard;
	/**
	 * ...
	 * @author Nicolas Philippe Lavoie
	 */
	public class Stages extends Properties
	{
		private var _mass_total:Number = 0, _mass_inherited:Number = 0;
		private var _cd:Number = 0.515;
		private var _area:Number = 1.227;
		private var _referencePlanet:String = "kerbin";
		private var _dV_Vac:Number = 0, _dV_Atm:Number = 0;
		private var _parts:Vector.<Parts>;
		private var _partsData:Vector.<Array>, _inheritedPartsData:Vector.<Array>;

		public function Stages() {
			_parts = new Vector.<Parts>();
			_partsData = new Vector.<Array>();
			_inheritedPartsData = new Vector.<Array>();
			_bitmap = new EmbedIcons.ImgStages();
			_img = _bitmap.bitmapData;
			_modPanel = new ModPanel(["0.515", "1.225", "kerbin"],["0123456789.", "0123456789.", "abcdefghijklmnopqrstuvwxyz"],[5, 5, 6]);
			
			//label Stage number
			_label = new TextField();
			_label.selectable = false;
            _label.autoSize = TextFieldAutoSize.LEFT;
            _label.mouseEnabled = false;
			_label.embedFonts = true;
			_label.defaultTextFormat = new TextFormat('arial', 22, GlobalVariables._whiteColor, true);
			_label.text = String(_num);
			_label.x = 50;
			_label.y = 40;
			addChild(_label);

			// Gestion de la souris
            addEventListener(MouseEvent.MOUSE_DOWN, _onMouseDown);
			addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, _onMouseDown);
			
			//modPanel stage event
			EventManager.addEventListener('modPanelOpened', function():void{if (GlobalVariables.currentPart != -1) _conditionalPartsDisplay() else {_modPanel.y = 36, _modPanel.x = 33 }});
			EventManager.addEventListener('modPanelClosed', function():void{_conditionalPartsDisplay(); GlobalVariables.currentPart = -1;});
			
			//linkMode event
			EventManager.addEventListener('linkIconTriggered', function():void{graphics.clear(); _draw(); if (GlobalVariables.linkMode) mouseEnabled = false else mouseEnabled = true});
			EventManager.addEventListener('linkUpdated', function():void{_resetIsLinked()});
			
			_draw();
		}
		
		//PRIVATE related functions
		
		 private function _draw():void {
			var tIcon:BitmapData = _img.clone(), mat:Matrix = new Matrix(), scaleFactor:Number = 0.51;
			if (GlobalVariables.linkMode)
				{
					var rc:Number = 1/3, gc:Number = 1/3, bc:Number = 1/3;
					tIcon.applyFilter(_bitmap.bitmapData, _bitmap.bitmapData.rect, new Point(), new ColorMatrixFilter([rc, gc, bc, 0, 0,rc, gc, bc, 0, 0, rc, gc, bc, 0, 0, 0, 0, 0, 1, 0]));
				}
			mat.scale(scaleFactor,scaleFactor);
			this.graphics.beginBitmapFill(tIcon,mat,false,true);
			this.graphics.drawRect(0, 0, _bitmap.width*scaleFactor, _bitmap.height*scaleFactor);
			this.graphics.endFill();
		}
		
		private function _deletePart(part:Parts):void {
			if (GlobalVariables.modPanelOpened) {Log.setText = "Can't delete part while in edit mode - ", EventManager.dispatchEvent(new Event('updateLog'));}
			else if (!GlobalVariables.linkMode && !isLinked) {
				var id:int = part.getNum;
				_parts[id].removeEventListener(MouseEvent.MIDDLE_MOUSE_DOWN, function ():void{_deletePart(part)});
				removeChild(_parts[id]);
				 _parts.splice(id, 1);
				 _partsData.splice(id, 1);
				_regenPartsNum();
				_rearangeParts();
			}
		}
		
		private function _regenParts():void {
			var partsData:Vector.<Array> = GlobalFunctions.cloneVecArray(_partsData);
			_partsData = new Vector.<Array>();
			if (_parts != null) {
				_parts = new Vector.<Parts>();
			}
			var len:int = partsData.length;
			for (var i:int = 0; i < len; i++) {
				addPart(partsData[i]);
			}
		}
		
		private function _rearangeParts():void{
			var locMatrix:Array = [[2, 0], [25, -13], [62, -13], [85, 0], [103, 32], [103, 63], [85, 99], [62, 112], [25, 112], [2, 99], [ -16, 63], [ -16, 32]];
			var len:int = _parts.length;
			
			for (var i:int = 0; i < len; i++){
				_parts[i].x = locMatrix[i][0];
				_parts[i].y = locMatrix[i][1];
			}
			if(_modPanel.parent != null) setChildIndex(_modPanel, numChildren - 1);
		}
		
		private function _regenPartsNum():void
		{
			var len:int = int(_parts.length);
			if (len != 0){
				for (var i:int = 0; i < len; i++)
				{
					_parts[i].setNum = i;
				}
				_parts[0].resetId = len;
			}
		}
		
		private function _srbEquilibriumBurn(refTime:Number, sfArray:Array):Array {
			Log.setText = "SRB thrust adjustement : ", EventManager.dispatchEvent(new Event('updateLog'));
			var returnArray:Array = new Array(), len:int = sfArray.length, factor:Number, numerator:Number = 0, divider:Number = 0;
			for (var i:int = 0; i < len ; i++) {
				factor = Math.round(sfArray[i][3] / refTime * 10) / 10;
				sfArray[i][1] *= factor;
				numerator += sfArray[i][1];
				divider += sfArray[i][1] / sfArray[i][2];
				Log.setText = String(i) + " =   " + String(factor * 100) + "%" + "   ", EventManager.dispatchEvent(new Event('appendLog'));
			}
			returnArray[0] = numerator;
			returnArray[1] = numerator / divider;
			
			return returnArray;
		}
		
		private function _engineEquilibriumBurn(engine:Object):Array {
			engine.burnTimeType = new Array();
			var returnArray:Array = new Array(), maxBurnTime:Number = 0, burnTimeType:Number = 0, factor:Number, numerator:Number = 0, divider:Number = 0;
			for (var index:String in engine.thrustType) {
				burnTimeType = engine.fuelType[index] * Constantes.ISPg0 * engine.ispType[index] / engine.thrustType[index];
				engine.burnTimeType[index] = burnTimeType;
				if (maxBurnTime < burnTimeType) maxBurnTime = burnTimeType;
			}
			//Equilibrating all thrust
			for (index in engine.thrustType) {
				if(engine.burnTimeType[index] > 0) {
					factor = Math.round(engine.burnTimeType[index] / maxBurnTime * 10) / 10;
					engine.thrustType[index] *= factor;
					numerator += engine.thrustType[index];
					divider += engine.thrustType[index] / engine.ispType[index];
					Log.setText = index + " =   " + String(factor * 100) + "%" + "   ", EventManager.dispatchEvent(new Event('appendLog'));
				}else Log.setText = index + " =   " + "no fuel!   ", EventManager.dispatchEvent(new Event('appendLog'));
			}
			returnArray[0] = numerator;
			returnArray[1] = numerator / divider;
			return returnArray;
		}
		
		private function _conditionalPartsDisplay():void {
			var len:int = int(_parts.length), protectedId:int = GlobalVariables.currentPart, isEditMode:Boolean = GlobalVariables.modPanelOpened, ipart:Parts;
			if (len != 0){
				for (var i:int = 0; i < len; i++)
				{
					ipart = _parts[i];
					if (isEditMode){
						if (protectedId != ipart.getNum) if (ipart.parent != null) removeChild(ipart);
					}else {
						if (ipart.parent == null) addChild(ipart);
					}
				}
			}
		}
		
		private function _resetIsLinked():void {
			isLinked = false;
			var len:int = _parts.length;
			for (var i:int = 0; i < len; i++)
			{
				_parts[i].isLinked = false;
			}
		}

		//PUBLIC or internal related functions
		internal function addPart(array:Array):void {
			if (GlobalVariables.modPanelOpened) {Log.setText = "Can't add part while in edit mode - ", EventManager.dispatchEvent(new Event('updateLog'));}
			else if (!GlobalVariables.linkMode) {
				if(_parts.length < 12) {
				var partsN:Parts = new Parts(array);
				partsN.addEventListener(MouseEvent.MIDDLE_MOUSE_DOWN, function ():void{_deletePart(partsN); });
				addChild(partsN);
				_parts.push(partsN);
				_partsData.push(array);
				 _regenPartsNum();
				_rearangeParts();
				}else {Log.setText = "Parts limit is 12 per stage - " , EventManager.dispatchEvent(new Event('updateLog'));}
			}
		}
		
		internal function applyPartsData():void {
			var generalPartList:Vector.<Array> = getParts.concat(_inheritedPartsData), len:int = generalPartList.length;

			_dV_Vac = 0;
			_dV_Atm = 0;
			
			mass_f_LOX = 0;
			mass_f_LF = 0;
			mass_f_SF = 0;
			mass_f_Mono = 0;
			mass_f_Xe = 0;
			
			payload = _mass_inherited;
			
			thrust_Vac = 0;
			thrust_Atm = 0;
			thrust_Atm_2 = 0;
			
			isp_Vac = 0;
			isp_Atm = 0;
			isp_Atm_2 = 0;
			
			if (len != 0){
				//one for each part type
				var id:String, hasEngine:Boolean = false, hasSRB:Boolean = false, part:Array;
				
				var type:int, qty:int, ipayload:Number, massLOX:Number, massLF:Number, massSF:Number, massMono:Number, massXe:Number, thrustAtm:Number, thrustAtm2:Number, thrustVac:Number, ispAtm:Number, ispAtm2:Number, ispVac:Number, fuel_factor:Number, thrust_factor:Number;
				
				var engineVac:Object = new Object();
				engineVac.thrustType = new Array();
				engineVac.fuelType = new Array();
				engineVac.divider = new Array();
				engineVac.sfTempData = new Array();
				engineVac.ispType = new Array();
				
				var engineAtm:Object = new Object();
				engineAtm.thrustType = new Array();
				engineAtm.fuelType = new Array();
				engineAtm.divider = new Array();
				engineAtm.sfTempData = new Array();
				engineAtm.ispType = new Array();
				
				var maxVacBurnTime:Number = 0, maxAtmBurnTime:Number = 0, tempBurnTime:Number = 0;
				
				for (var i:int = 0; i < len; i++)
				{
					part = generalPartList[i];
					
					type = part[0];
					//var label:String part[;
					qty = part[2];
					ipayload = part[3];
					massLOX = part[4];
					massLF = part[5];
					massSF = part[6];
					massMono = part[7];
					massXe = part[8];
					thrustAtm = part[9];
					thrustAtm2 = part[10];
					thrustVac = part[11];
					ispAtm = part[12];
					ispAtm2 = part[13];
					ispVac = part[14];
					fuel_factor = part[15] / 100;
					thrust_factor = part[16] / 100;
					
					
					mass_f_LOX += qty * fuel_factor * massLOX;
					mass_f_LF += qty * fuel_factor * massLF;
					mass_f_SF += qty * fuel_factor * massSF;
					mass_f_Mono += qty * fuel_factor * massMono;
					mass_f_Xe += qty * fuel_factor * massXe;
					payload += qty * ipayload;
					
					//Preparation for calculation for ideal burn equilibrium between engineVac type
					if (thrustAtm > 0 && type != 10) {
						hasEngine = true
						if (type == 6) {
							hasSRB = true;
							id = "SF";
							tempBurnTime = fuel_factor * massSF * Constantes.ISPg0 * ispVac / thrustVac / thrust_factor;
							engineVac.sfTempData.push([massSF * fuel_factor, thrustVac * thrust_factor * qty, ispVac, tempBurnTime])
							if (maxVacBurnTime < tempBurnTime) maxVacBurnTime = tempBurnTime;
							
							tempBurnTime = fuel_factor * massSF * Constantes.ISPg0 * ispAtm / thrustAtm / thrust_factor;
							engineAtm.sfTempData.push([massSF * fuel_factor, thrustAtm * thrust_factor * qty, ispAtm, tempBurnTime])
							if (maxAtmBurnTime < tempBurnTime) maxAtmBurnTime = tempBurnTime;
							
						}else if (type > 4) {
							if (type == 5) id = "LF"
							else if (type == 7) id = "MF"
							else if (type == 8) id = "XF"
							else if (type == 9) id = "LF"
							
							if (isNaN(engineVac.thrustType[id])) engineVac.thrustType[id] = 0;
							if (isNaN(engineVac.divider[id])) engineVac.divider[id] = 0;
							if (isNaN(engineAtm.thrustType[id])) engineAtm.thrustType[id] = 0;
							if (isNaN(engineAtm.divider[id])) engineAtm.divider[id] = 0;
							
							engineVac.thrustType[id] += qty * thrust_factor * thrustVac;
							engineVac.divider[id] += qty * thrust_factor * thrustVac / ispVac;
							engineAtm.thrustType[id] += qty * thrust_factor * thrustAtm;
							engineAtm.divider[id] += qty * thrust_factor * thrustAtm / ispAtm;
						}
					}
				}
				
				if(hasSRB) {
					engineVac.sfTempData = _srbEquilibriumBurn(maxVacBurnTime, engineVac.sfTempData);
					engineVac.thrustType["SF"] = engineVac.sfTempData[0];
					engineVac.ispType["SF"] = engineVac.sfTempData[1];
					engineVac.sfTempData = null;
					engineAtm.sfTempData = _srbEquilibriumBurn(maxAtmBurnTime, engineAtm.sfTempData);
					engineAtm.thrustType["SF"] = engineAtm.sfTempData[0];
					engineAtm.ispType["SF"] = engineAtm.sfTempData[1];
					engineAtm.sfTempData = null;
				}
				
				if(hasEngine) {
					engineVac.fuelType["LF"] = mass_f_LF + mass_f_LOX;
					engineVac.fuelType["SF"] = mass_f_SF;
					engineVac.fuelType["MF"] = mass_f_Mono;
					engineVac.fuelType["XF"] = mass_f_Xe;
					engineAtm.fuelType["LF"] = mass_f_LF + mass_f_LOX;
					engineAtm.fuelType["SF"] = mass_f_SF;
					engineAtm.fuelType["MF"] = mass_f_Mono;
					engineAtm.fuelType["XF"] = mass_f_Xe;
					
					engineVac.ispType["LF"] = engineVac.thrustType["LF"] / engineVac.divider["LF"];
					engineVac.ispType["MF"] = engineVac.thrustType["MF"] / engineVac.divider["MF"];
					engineVac.ispType["XF"] = engineVac.thrustType["XF"] / engineVac.divider["XF"];
					engineAtm.ispType["LF"] = engineAtm.thrustType["LF"] / engineAtm.divider["LF"];
					engineAtm.ispType["MF"] = engineAtm.thrustType["MF"] / engineAtm.divider["MF"];
					engineAtm.ispType["XF"] = engineAtm.thrustType["XF"] / engineAtm.divider["XF"];
					
					Log.setText = "Vaccum thrust adj. : ", EventManager.dispatchEvent(new Event('appendLog'));
					engineVac.sfTempData = _engineEquilibriumBurn(engineVac);
					Log.setText = "Atm. thrust adj. : ", EventManager.dispatchEvent(new Event('appendLog'));
					engineAtm.sfTempData = _engineEquilibriumBurn(engineAtm);
					thrust_Vac = engineVac.sfTempData[0];
					isp_Vac = engineVac.sfTempData[1];
					thrust_Atm = engineAtm.sfTempData[0];
					isp_Atm = engineAtm.sfTempData[1];
					if (mass_f_LOX < mass_f_LF * 1.2) {Log.setText = "Warning : maybe not enough LOX in tanks from a complete burn - ", EventManager.dispatchEvent(new Event('appendLog'))}
				}
			}
			mass_total = payload + mass_f_LOX + mass_f_LF + mass_f_SF + mass_f_Mono + mass_f_Xe;
			dV_Vac = Constantes.ISPg0 * isp_Vac * Math.log(mass_total / payload);
			dV_Atm = Constantes.ISPg0 * isp_Atm * Math.log(mass_total / payload);
		}

		internal function getPartPos(value:int):Array {
			if (_parts.length > value) return [_parts[value].x, _parts[value].y];
			else return new Array();
		}
		
		internal function partLinked(index:int):void {
			_parts[index].isLinked = true;
		}
		
		override protected function _closeModPanel():void {
			var array:Array = _modPanel.getModifiedData;
			//Tranfert des textfields vers les données internes
			_cd = array[0];
			_area = array[1];
			_referencePlanet = array[2];
			super._closeModPanel();
		}
		
		//EVENTs related functions
		override protected function _openModPanel(event:Event):void {
			if (!GlobalVariables.linkMode) {
				Log.setText = "Stage : Coefficient of drag (Cd), Area of drag (m^2), Planet of reference (duna, eve, gilly, ike, kerbin, laythe, minmus, mun) - Press Enter to accept - ", EventManager.dispatchEvent(new Event('appendLog'));
				super._openModPanel(event);
			}
		}

		private function _onMouseDown(event:Event):void {
			GlobalVariables.activeStage = _num;
			Log.setText = "Stage " + _num + " selected - " , EventManager.dispatchEvent(new Event('updateLog'));
			EventManager.dispatchEvent(new Event('selectStage'));
		}
		
		override protected function _onKeyUp(event:KeyboardEvent):void {
			Log.setText = "Text input (top to bottom) : quantity or payload mass (t), fuel in tank (%), thrust for engine (%) - Press Enter to accept - ", EventManager.dispatchEvent(new Event('updateLog'));
			super._onKeyUp(event);
		}
		
		//GETTERS AND SETTERS related functions
		internal function set setNum(value:int):void {
			_num = value;
			_label.text = String(_num);
		}
		
		internal function get getNum():int {
			return int(_num);
		}
		
		internal function get cd():Number {
			return _cd;
		}
		
		internal function set cd(value:Number):void {
			if (isNaN(value)) _cd = 0;
			else _cd = Math.round(value * Constantes.precision) / Constantes.precision;
		}
		
		internal function get area():Number {
			return _area;
		}
		
		internal function set area(value:Number):void {
			if (isNaN(value)) _area = 0;
			else _area = Math.round(value * Constantes.precision) / Constantes.precision;
		}
		
		internal function get refPlanet():String {
			return _referencePlanet;
		}
		
		internal function set refPlanet(value:String):void {
			_referencePlanet = value;
		}
		
		internal function set dV_Vac(value:Number):void {
			if (isNaN(value)) _dV_Vac = 0;
			else _dV_Vac = Math.round(value * 10) / 10;
		}
		
		internal function get dV_Vac():Number {
			return Number(_dV_Vac);
		}
		
		internal function set dV_Atm(value:Number):void {
			if (isNaN(value)) dV_Atm = 0;
			else _dV_Atm = Math.round(value * 10) / 10;
		}
		
		internal function get dV_Atm():Number {
			return Number(_dV_Atm);
		}
		
		internal function set mass_total(value:Number):void {
			_mass_total = Math.round(value * Constantes.precision) / Constantes.precision;
		}
		
		internal function get mass_total():Number {
			return Number(_mass_total);
		}
		
		internal function set mass_inherited(value:Number):void {
			_mass_inherited = Math.round(value * Constantes.precision) / Constantes.precision;
		}
		
		internal function get mass_inherited():Number {
			return Number(_mass_inherited);
		}
		
		internal function get getStageData():Array {
			if (Constantes[_referencePlanet] == null) {Log.setText = _referencePlanet + " is not a valid planet name - kerbin is now assigned as default reference planet for this stage - ";EventManager.dispatchEvent(new Event("updateLog")); _referencePlanet = "kerbin"; }
			var data:Array = [mass_total, payload, mass_f_LOX, mass_f_LF, mass_f_Mono, mass_f_Xe, mass_f_SF, thrust_Vac, thrust_Atm, isp_Vac, isp_Atm, _dV_Vac, _dV_Atm, _cd, _area, Constantes[_referencePlanet][0]];
			return data;
		}
		
		internal function get getParts():Vector.<Array> {
			var len:int = _parts.length, part:Parts;
			_partsData = new Vector.<Array>();
			for (var i:int = 0; i < len; i++)
			{
				part = _parts[i];
				_partsData.push([part.type, part.label, part._quantity, part.payload, part.mass_f_LOX, part.mass_f_LF, part.mass_f_SF, part.mass_f_Mono, part.mass_f_Xe, part.thrust_Atm, part.thrust_Atm_2, part.thrust_Vac, part.isp_Atm, part.isp_Atm_2, part.isp_Vac, part._fuel_factor, part._thrust_factor]);
			}
			
			return GlobalFunctions.cloneVecArray(_partsData);
		}
		
		internal function get getPartsForInherited():Vector.<Array> {
			var len:int = _parts.length, part:Parts, partsData:Vector.<Array> = new Vector.<Array>(), payload:Number, massLOX:Number, massLF:Number, massSF:Number, massMono:Number, massXe:Number;
			for (var i:int = 0; i < len; i++)
			{
				part = _parts[i];
				partsData.push([part.type, part.label, part._quantity, 0, 0, 0, 0, 0, 0, part.thrust_Atm, part.thrust_Atm_2, part.thrust_Vac, part.isp_Atm, part.isp_Atm_2, part.isp_Vac, part._fuel_factor, part._thrust_factor]);
			}
			
			return partsData;
		}
		
		internal function set setParts(value:Vector.<Array>):void {
			_partsData = value;
			_regenParts();
		}
		
		internal function set setInheritedPartsData(value:Vector.<Array>):void {
			_inheritedPartsData = value;
		}
	}
}