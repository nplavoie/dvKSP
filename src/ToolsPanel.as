package 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Nicolas Philippe Lavoie
	 */
	public class ToolsPanel extends Sprite
	{
		private var _infoPanel:Sprite;
		private var _deleteIcon:Sprite;
		private var _insertIcon:Sprite;
		private var _parachuteIcon:Sprite;
		private var _copyIcon:Sprite;
		private var _applyIcon:Sprite;
		private var _linkIcon:Sprite;
		
		public function ToolsPanel() 
		{
			_drawIcons();
		}
		
		private function _drawIcons():void{
			_deleteIcon = new Sprite();
			_insertIcon = new Sprite();
			_parachuteIcon = new Sprite();
			_copyIcon = new Sprite();
			_applyIcon = new Sprite();
			_linkIcon = new Sprite();
			
			var mat:Matrix = new Matrix();
			var scaleFactor:Number = 0.45;
			mat.scale(scaleFactor, scaleFactor);
			
			//addChild(_parachuteIcon);
			addChild(_deleteIcon);
			addChild(_copyIcon);
			addChild(_insertIcon);
			addChild(_applyIcon);
			addChild(_linkIcon);
			
			_insertIcon.addEventListener(MouseEvent.MOUSE_OVER, function():void{Log.setText="Insert a stage in front of the selected stage - "; EventManager.dispatchEvent(new Event('updateLog')); });
			_insertIcon.addEventListener(MouseEvent.MOUSE_UP, function():void{EventManager.dispatchEvent(new Event('insertIconTriggered')); });
			_deleteIcon.addEventListener(MouseEvent.MOUSE_OVER, function():void{Log.setText="Delete the selected stage - "; EventManager.dispatchEvent(new Event('updateLog')); });
			_deleteIcon.addEventListener(MouseEvent.MOUSE_UP, function():void{EventManager.dispatchEvent(new Event('deleteIconTriggered')); });
			_applyIcon.addEventListener(MouseEvent.MOUSE_OVER, function():void{Log.setText="Apply all the parts information into the selected stage (but not for the other stages) - "; EventManager.dispatchEvent(new Event('updateLog')); });
			_applyIcon.addEventListener(MouseEvent.MOUSE_UP, function():void{EventManager.dispatchEvent(new Event('applyIconTriggered')); });
			_copyIcon.addEventListener(MouseEvent.MOUSE_OVER, function():void{Log.setText="Clone the selected stage - "; EventManager.dispatchEvent(new Event('updateLog')); });
			_copyIcon.addEventListener(MouseEvent.MOUSE_UP, function():void{EventManager.dispatchEvent(new Event('copyIconTriggered')); });
			_linkIcon.addEventListener(MouseEvent.MOUSE_OVER, function():void{Log.setText="Link parts between stages - "; EventManager.dispatchEvent(new Event('updateLog')); });
			_linkIcon.addEventListener(MouseEvent.MOUSE_UP, function():void{GlobalVariables.linkMode = true; GlobalVariables.currentPart = -1; EventManager.dispatchEvent(new Event('linkIconTriggered'));Log.setText="Click on a part or press ESCAPE to exit link mode - Parts can't be deleted or modified during link mode - "; EventManager.dispatchEvent(new Event('updateLog')); });
			
			var bmap:Bitmap = new EmbedIcons.ImgIns(); 
			var bmdata:BitmapData = bmap.bitmapData;
			with(_insertIcon.graphics){
				beginBitmapFill(bmdata,mat,false,true);
				drawRect(0, 0, bmap.width*scaleFactor, bmap.height*scaleFactor);
				graphics.endFill();
			}
			bmap = new EmbedIcons.ImgPara(); 
			bmdata = bmap.bitmapData;
			with(_parachuteIcon.graphics){
				beginBitmapFill(bmdata,mat,false,true);
				drawRect(0, 0, bmap.width*scaleFactor, bmap.height*scaleFactor);
				graphics.endFill();
			}
			bmap = new EmbedIcons.ImgDel(); 
			bmdata = bmap.bitmapData;
			with(_deleteIcon.graphics){
				beginBitmapFill(bmdata,mat,false,true);
				drawRect(0, 0, bmap.width*scaleFactor, bmap.height*scaleFactor);
				graphics.endFill();
			}
			bmap = new EmbedIcons.ImgCopy(); 
			bmdata = bmap.bitmapData;
			with(_copyIcon.graphics){
				beginBitmapFill(bmdata,mat,false,true);
				drawRect(0, 0, bmap.width*scaleFactor, bmap.height*scaleFactor);
				graphics.endFill();
			}
			bmap = new EmbedIcons.ImgApply(); 
			bmdata = bmap.bitmapData;
			with(_applyIcon.graphics){
				beginBitmapFill(bmdata,mat,false,true);
				drawRect(0, 0, bmap.width*scaleFactor, bmap.height*scaleFactor);
				graphics.endFill();
			}
			bmap = new EmbedIcons.ImgLink(); 
			bmdata = bmap.bitmapData;
			with(_linkIcon.graphics){
				beginBitmapFill(bmdata,mat,false,true);
				drawRect(0, 0, bmap.width*scaleFactor, bmap.height*scaleFactor);
				graphics.endFill();
			}
			var x1:int= 10
			var x2:int = 88;
			var y1:int = 31;
			var y2:int = 74;
			var x3:int = 49;
			
			_deleteIcon.x = x1;
			_deleteIcon.y = y1;
			_insertIcon.x = x2;
			_insertIcon.y = y1;
			_copyIcon.x = x2;
			_copyIcon.y = y2;
			/*_parachuteIcon.x = x1;
			_parachuteIcon.y = y2;*/
			_applyIcon.x = x3;
			_applyIcon.y = 87;
			_linkIcon.x = x1;
			_linkIcon.y = y2;
		}
	}
}