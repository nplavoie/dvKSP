package 
{
	import flash.display.Shape;
	import flash.display.Sprite;
	import fl.controls.ComboBox;
	import fl.data.DataProvider;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.registerClassAlias;
	import flash.events.MouseEvent;
	
	/**
	 * ...
	 * @author Nicolas Philippe Lavoie
	 */
	public class StageMap extends Sprite
	{
		private var _combobox:ComboBox, _combobox2:ComboBox;
		private var _mouseRelativePosition:Array, _oldMousePosition:Array, _linkInformation:Array;
		private var _myLoader:URLLoader;
		private var _stages:Vector.<Stages>;
		private var _selectedStage:Stages;
		private var _toolsPanel:ToolsPanel;
		private var _infoPanel:InfoPanel;
		private var _xml:XML;
		private var _maxStage:int = 14;
		private var _xLimit:int = 225;
		private var _link:Sprite;

		public function StageMap() 
		{
			_link = new Sprite();
			_link.mouseEnabled = false;
			addChild(_link);
			
			_infoPanel = new InfoPanel();
			_infoPanel.mouseEnabled = false;
			_infoPanel.x = 10;
			_infoPanel.y = 200;
			addChild(_infoPanel);
			
			Log.setText = "StageMap loaded - ", EventManager.dispatchEvent(new Event('appendLog'));
			
			// Charger le fichier des pièces
			_myLoader = new URLLoader();
			_myLoader.load(new URLRequest("xml/Parts.xml"));
			_myLoader.addEventListener(Event.COMPLETE, _processXML);

			//Add the first stage			
			_resetStage();
			
			//Mouse Event dispatch
			//create invisible mask for mouse to click on
			var rectangle:Shape = new Shape; // initializing the variable named rectangle
			rectangle.graphics.beginFill(0x000000,0); // choosing the colour for the fill, here it is red
			rectangle.graphics.drawRect(0, 0, GlobalVariables.stageW, GlobalVariables.stageH); // (x spacing, y spacing, width, height)
			rectangle.graphics.endFill(); // not always needed but I like to put it in to end the fill
			addChild(rectangle); // adds the rectangle to the stage
			addEventListener(MouseEvent.MOUSE_UP, _onMouseUp);
			
			//selected stage event
			EventManager.addEventListener('selectStage', _onStageSelect);
			EventManager.addEventListener('selectStage', _onStageEvent);

			//icons stage event
			EventManager.addEventListener('insertIconTriggered', function():void{_insertStage(_selectedStage.getNum + 1)});
			EventManager.addEventListener('deleteIconTriggered', function():void{_deleteStage(_selectedStage.getNum)});
			EventManager.addEventListener('applyIconTriggered', function():void{_updateStageData4Info(_selectedStage.getNum)});
			EventManager.addEventListener('linkIconTriggered', function():void {if (_toolsPanel.parent != null) removeChild(_toolsPanel)});
			EventManager.addEventListener('copyIconTriggered', function():void{_cloneStage()});
			
			//modPanel stage event
			EventManager.addEventListener('modPanelOpened', function():void{if (_toolsPanel.parent != null) removeChild(_toolsPanel); GlobalFunctions.removeAllChildren(_link);});
			EventManager.addEventListener('modPanelClosed', function():void{if (_toolsPanel.parent == null) addChild(_toolsPanel); _updateLink(); _updateVisualLinks(); });
		}
		
		//PRIVATE related functions
		private function _addMenu():void {
			if(_combobox == null){
			var comboData:Array = new Array( {label:"Equipement", data:1}, {label:"Tank (LOX/LF)", data:2 }, {label:"Tank (Monopro)", data:3 }, {label:"Tank (Xenon)", data:4 }, {label:"Engine (LOX/LF)", data:5 }, {label:"Engine (SRB)", data:6 }, {label:"Engine (Monopro)", data:7 }, {label:"Engine (Xenon)", data:8 }, {label:"Engine-tank (LOX/LF)", data:9 } );
			_combobox = new ComboBox();
			_combobox.dropdownWidth = 140; 
			_combobox.width = 140;  
			_combobox.move(10, 25); 
			_combobox.prompt = "Select type"; 
			_combobox.dataProvider = new DataProvider(comboData); 
			_combobox.addEventListener(Event.CHANGE, _onChangeHandler); 
			_combobox.addEventListener(MouseEvent.MIDDLE_MOUSE_DOWN, _onMidMouseDownCombobox);
			addChild(_combobox);
			}
		}
		
		private function _addPartsMenu(type:int):void {
			if(_combobox2 != null) {
			removeChild(_combobox2);
			_combobox2 = null;
			}
			if (_combobox2 == null) {
				var comboData:Array = new Array();
				for each(var part:XML in _xml..TYPE.(@ID == type).PART) {
					comboData.push( { type:type, label:part.@NAME, payload:part.@PAYLOAD , mass_LOX:part.@MASS_LOX, mass_LF:part.@MASS_LF, mass_SF:part.@MASS_SF, mass_MP:part.@MASS_MP, mass_Xe:part.@MASS_XE, thrust_atm:part.@THRUST_ATM, thrust_atm_2:part.@THRUST_ATM_2, thrust_vac:part.@THRUST_VAC, isp_atm:part.@ISP_ATM, isp_atm_2:part.@ISP_ATM_2, isp_vac:part.@ISP_VAC, fuel_factor:100, thrust_factor:100});
				}
			_combobox2 = new ComboBox();
			_combobox2.dropdownWidth = 155; 
			_combobox2.width = 155;  
			_combobox2.move(10, 47);
			_combobox2.prompt = "Select part"; 
			_combobox2.dataProvider = new DataProvider(comboData); 
			_combobox2.addEventListener(MouseEvent.MIDDLE_MOUSE_DOWN, _onMidMouseDownCombobox2);
			addChild(_combobox2);
			}
		}
		
		private function _updateInfoPanel():void {
			if(_toolsPanel == null) {
			_toolsPanel = new ToolsPanel();
			}
			if (_toolsPanel.parent == null && !GlobalVariables.modPanelOpened){
				addChild(_toolsPanel);
			}else if(_toolsPanel.parent != null) setChildIndex(_toolsPanel, numChildren - 1);
			_toolsPanel.x = _selectedStage.x;
			_toolsPanel.y = _selectedStage.y;
			_infoPanel.updateData = [_selectedStage.getNum].concat(_selectedStage.getStageData);
		}
		
		private function _resetStage():void {
			if (_stages != null) {
				var len:int = _stages.length;
				for (var i:int = 0; i < len; i++) {
					removeChild(_stages[i]);
				}
			}
			
			// initialisation des liens et du vecteur maître
			_linkInformation = new Array();
            _stages = new Vector.<Stages>();
			
			var stageI:Stages = new Stages();
			stageI.x = _xLimit;
			stageI.y = 30;
			// Gestion de la souris
			stageI.addEventListener(MouseEvent.MOUSE_DOWN, _onMouseDownDrag);
			addChild(stageI);
			_stages.push(stageI);
			Log.setText = "Stage reset - ", EventManager.dispatchEvent(new Event('appendLog'));
			_selectedStage = _stages[0];
			_updateInfoPanel();
		}
		
		private function _insertStage(value:int):void {
			if (_stages.length < 14) {
				var stageN:Stages = new Stages(), selectedNum:int = _selectedStage.getNum;
				
				// Gestion de la souris
				stageN.addEventListener(MouseEvent.MOUSE_DOWN, _onMouseDownDrag);
				addChild(stageN);
				_stages.splice(value, 0, stageN);
				_regenStagesNum();
				if(selectedNum < _stages.length) _selectedStage = _stages[selectedNum];
				_updateInfoPanel();
				_linkInformation = _shiftLinkedStagePositions(1);
				_updateVisualLinks();
				Log.setText = "Stage " + String(value) + " inserted - ", EventManager.dispatchEvent(new Event('appendLog'));
				}
		}
		
		private function _cloneStage():void {
			if (_stages.length < 14) {
				var stageN:Stages = new Stages(), selectedNum:int = _selectedStage.getNum;
				stageN.setParts = _selectedStage.getParts;
				
				// Gestion de la souris
				stageN.addEventListener(MouseEvent.MOUSE_DOWN, _onMouseDownDrag);
				
				addChild(stageN);
				_stages.splice(_selectedStage.getNum + 1, 0, stageN);
				_regenStagesNum();
				_selectedStage = _stages[selectedNum];
				_updateInfoPanel();
				_linkInformation = _shiftLinkedStagePositions(1);
				_updateVisualLinks();
				Log.setText = "Stage " + String(_selectedStage.getNum + 1) + " inserted - ", EventManager.dispatchEvent(new Event('appendLog'));
			}
		}
		
		private function _deleteStage(value:int):void {
			if (value == 0) Log.setText = "Can't delete stage 0 - ", EventManager.dispatchEvent(new Event('appendLog'));
			else {
				var maxNum:int = _stages.length - 1, selectedNum:int = _selectedStage.getNum;
				
				// Gestion de la souris
				_selectedStage.removeEventListener(MouseEvent.MOUSE_DOWN, _onMouseDownDrag);
				removeChild(_stages[value]);
				_stages.splice(selectedNum, 1);
				_regenStagesNum();
				if (selectedNum == maxNum) _selectedStage = _stages[maxNum - 1];
				_updateInfoPanel();
				_linkInformation = _shiftLinkedStagePositions(-1);
				_updateVisualLinks();
				Log.setText = "Stage " + String(value) + " deleted - ", EventManager.dispatchEvent(new Event('appendLog'));
			}
		}
		
		private function _regenStagesNum():void	{
			var len:int = _stages.length, MainstageW:int = GlobalVariables.stageW, stageN_width:int = _stages[0].width + 25, offset_x:int = _xLimit, maxPerRow:int = Math.floor((MainstageW - offset_x) / stageN_width);
			for (var i:int = 0; i < len; i++)
			{
				_stages[i].setNum = i;
				_stages[i].x = offset_x  + (i % maxPerRow) * stageN_width;
				_stages[i].y = 30  + Math.floor(i / maxPerRow) * stageN_width;
			}
			_stages[0].resetId = len;
		}
		
		private function _updateInheritedParts():void {
			var importVector:Vector.<Array> = new Vector.<Array>(), importedParts:Vector.<Array>, len:int = _stages.length;
			for (var j:int = 0; j < len; j++) {
				_stages[j].setInheritedPartsData = importVector;
			}
			var e:String, i:String, p:String;
			for (e in _linkInformation) {
				for (i in _linkInformation[e]) {
					importVector = new Vector.<Array>();	
					for (p in _linkInformation[e][i]) {
						//set inherited part to stage and islinked part are set true
						_stages[i].isLinked = true;
						_stages[i].partLinked(int(p));
						importVector.push(_stages[i].getPartsForInherited[p]);
					}
					if (importVector.length != 0) {
						_stages[e].setInheritedPartsData = importVector;
						//_stages[e].isLinked = true;
					} 
				}
			}
			
		}
		
		private function _shiftLinkedStagePositions(value:int):Array {
			var e:String, i:String, shiftedLinks:Array = new Array();
			for (e in _linkInformation) {
				if (shiftedLinks[int(e) + value] == null) shiftedLinks[int(e) + value] = new Array();
				for (i in _linkInformation[e]) {
					if (shiftedLinks[int(e) + value][int(i) + value] == null) shiftedLinks[int(e) + value][int(i) + value] = new Array();
					shiftedLinks[int(e) + value][int(i) + value] = _linkInformation[e][i]
				}
			}
			return shiftedLinks;
		}
		
		private function _updateVisualLinks():void {
			if (!GlobalVariables.modPanelOpened) {
				GlobalFunctions.removeAllChildren(_link);
				var e:String, i:String, p:String, dashy:DashedLine, len:int = _stages.length;
				for (e in _linkInformation) {
					for (i in _linkInformation[e]) {
						for (p in _linkInformation[e][i]) {
							//draw a line for each link
							if (len > int(e) && _stages[i].getPartPos(int(p)).length != 0) {
							dashy = new DashedLine(4,0xFFFFFF,new Array(8,4,2,4));
							dashy.moveTo(_stages[e].x + 55, _stages[e].y + 70);
							dashy.lineTo(_stages[i].x + _stages[i].getPartPos(int(p))[0] + 13, _stages[i].y + _stages[i].getPartPos(int(p))[1] + 13);
							dashy.link = [e, i, p];
							dashy.addEventListener(MouseEvent.MIDDLE_CLICK, function():void{EventManager.dispatchEvent(new Event('onDashedLineMidMouse')) });
							dashy.addEventListener(MouseEvent.MIDDLE_CLICK, function(evt:Event):void{if (evt.currentTarget.link != null) _deleteLink(evt.currentTarget.link[0], evt.currentTarget.link[1], evt.currentTarget.link[2])});
							_link.addChild(dashy);
							} else	_deleteLink(e, i, p);
						}
					}
				}
				setChildIndex(_link, numChildren - 1);
			}
		}
		
		private function _deleteLink(e:String, i:String, p:String):void {
			var array:Array = _linkInformation[e][i];
			array.splice(p, 1);
			_updateLink();
			_updateVisualLinks();
		}
		
		//INTERNALs related functions
		
		internal function exitLinkMode():void {
			GlobalVariables.linkMode = false;
			_updateLink();
			EventManager.dispatchEvent(new Event('linkIconTriggered'));
			if (_toolsPanel.parent == null) addChild(_toolsPanel);
			
		}
		
		internal function _updateAllStagesData4Info():void {
			var len:int = _stages.length;
			for (var i:int = 0; i < len; i++) {
				_updateStageData4Info(i);
			}
		}

		//EVENT related functions
		private function _onMouseUp(e:Event):void {
			if(GlobalVariables.activeEditedStage > -1) {
				if (!_stages[GlobalVariables.activeEditedStage].hitTestPoint(mouseX, mouseY)) EventManager.dispatchEvent(new Event('stageMouseOut'));
			}
		}
		
		private function _processXML(e:Event):void {
			_xml = new XML(e.target.data);
			_addMenu();
		}
		
		private function _onChangeHandler(event:Event):void { 
			// do something based on the selected item's value
			var data:int = _combobox.selectedItem.data;
			if (data == 1) {
				if (_combobox2 != null) {
					removeChild(_combobox2);
					_combobox2 = null;
				}
			}else _addPartsMenu(data);
		}
		
		private function _onStageEvent(event:Event):void {
			if (_selectedStage.getNum != GlobalVariables.activeStage) {
				var activeStage:int = GlobalVariables.activeStage;
				if (!GlobalVariables.linkMode) {
					_selectedStage = _stages[activeStage];
					setChildIndex(_selectedStage, numChildren - 2);
					_updateVisualLinks();
					_updateInfoPanel();
				}
			}
		}
		
		private function _onStageSelect(event:Event):void {
			var activeStage:int = GlobalVariables.activeStage;
			var activePart:int = GlobalVariables.currentPart;
			var activePartType:int = GlobalVariables.currentPartType;
			
			if (GlobalVariables.linkMode) {
				if (_selectedStage.getNum <= _stages[activeStage].getNum) {
					Log.setText = "Stage " + String(_stages[activeStage].getNum) + " can't be the end link node - ", EventManager.dispatchEvent(new Event('appendLog'));
				}
				else if (activePart > -1 && (activePartType == 5 || activePartType == 7 || activePartType == 8 || activePartType == 9)) {
					var exportStage:int = _selectedStage.getNum;
					if (_linkInformation[exportStage] == null) _linkInformation[exportStage] = new Array();
					if (_linkInformation[exportStage][activeStage] == null) _linkInformation[exportStage][activeStage] = new Array();
					_linkInformation[exportStage][activeStage][activePart] = "linked";
					exitLinkMode();
				}else {Log.setText = "This part can't be linked - Press Escape to exit link mode at any time - ", EventManager.dispatchEvent(new Event('appendLog')); }
			}	
		}
		
		private function _updateStageData4Info(id:int):void {
			if (id > 0) {
				_stages[id].mass_inherited = _stages[id - 1].mass_total;
			}
			_stages[id].applyPartsData();
			_updateInfoPanel();
		}
		
		private function _onMidMouseDownCombobox(event:Event):void {
			if (_combobox.selectedItem != null) {
				switch(_combobox.selectedItem.data) {
				case 1:
					_selectedStage.addPart([1, "Payload", 1, 1]);
					break;
				}
			}
		}
		
		private function _onMidMouseDownCombobox2(event:Event):void {
			if (_combobox2.selectedItem != null) {
				var dataArray:Array = GlobalFunctions.Obj2Array(_combobox2.selectedItem);
				_selectedStage.addPart(dataArray);
			}
		}
		
		private function _onMouseDownDrag(event:MouseEvent):void {
			if (!GlobalVariables.linkMode) {
				_oldMousePosition = [mouseX, mouseY];
				addEventListener( MouseEvent.MOUSE_MOVE, _drag );
				addEventListener( MouseEvent.MOUSE_UP, _endDrag );
				addEventListener( MouseEvent.MOUSE_OUT, _endDrag );
				_mouseRelativePosition = [mouseX - _selectedStage.x, mouseY - _selectedStage.y];
			}
		}
		
		private function _drag(event:MouseEvent):void {
			var mouseSpeed:Array = [this.mouseX - _oldMousePosition[0], this.mouseY - _oldMousePosition[1]];
			_selectedStage.x = _toolsPanel.x = this.mouseX - _mouseRelativePosition[0] + Math.ceil(mouseSpeed[0] * 1.2);
			_selectedStage.y = _toolsPanel.y = this.mouseY - _mouseRelativePosition[1] + Math.ceil(mouseSpeed[1] * 1.2);
			if (_selectedStage.x < _xLimit) {_selectedStage.x = _toolsPanel.x = _xLimit}
			if (_selectedStage.y < 30) {_selectedStage.y = _toolsPanel.y = 30}
			else if (_selectedStage.y > 166) {_selectedStage.y = _toolsPanel.y = 166}
			_oldMousePosition = [this.mouseX, this.mouseY];
			_link.visible = false;
		}

		private function _endDrag(event:MouseEvent):void {
			_oldMousePosition = [mouseX, mouseY];
			removeEventListener( MouseEvent.MOUSE_MOVE, _drag );
			removeEventListener( MouseEvent.MOUSE_UP, _endDrag );
			removeEventListener( MouseEvent.MOUSE_OUT, _endDrag );
			_updateVisualLinks();
			_updateInfoPanel();
			_link.visible = true;
		}
		
		private function _updateLink():void {
			EventManager.dispatchEvent(new Event('linkUpdated'));
			_updateInheritedParts();
		}
		
		//GETTERs related functions
		internal function get getData2Save():Object {
			var mySave:Object = new Object(), len:int = _stages.length, stage:Stages;
			
			for (var i:int = 0; i < len; i++) {
				stage = _stages[i];
				mySave[i] = stage.getParts;
				mySave["extra" + i] = new Array(stage.x, stage.y, stage.cd, stage.area, stage.refPlanet);
			}
			mySave.links = _linkInformation;
			return mySave;
		}
		
		internal function set setLoadedData(object:Object):void {
			_resetStage();
			var index:int, vectorArray:Vector.<Array>;
			var id:String, subId:String;
			for (id in object) {
				vectorArray = new Vector.<Array>();
				if (!isNaN(Number(id))) {
					index = int(id);
					if (index > _stages.length - 1) _insertStage(_stages.length);
					for (subId in object[id]) {
						vectorArray[subId] = object[id][subId];
					}
					_stages[index].setParts = vectorArray;
				}else if (id == "links") _linkInformation = object.links;
				else {
					index = int(id.charAt(id.length - 1));
					_stages[index].x = object[id][0], _stages[index].y = object[id][1], _stages[index].cd = object[id][2], _stages[index].area = object[id][3], _stages[index].refPlanet = object[id][4];
				}
			}
			_stages[0].setNum = 0;
			_selectedStage = _stages[0];
			_updateLink();
			_updateVisualLinks();
			_updateInfoPanel();
		}
	}
}