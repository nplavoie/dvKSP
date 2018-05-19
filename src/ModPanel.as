package 
{
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	/**
	 * ...
	 * @author Nicolas Philippe Lavoie
	 */
	public class ModPanel extends Sprite
	{
		private var _textfields:Vector.<TextField>;
		private var _len:int;
		
		public function ModPanel(textArray:Array, restrictArray:Array, charArray:Array) 
		{
			var txt:TextField;
			_len = textArray.length;
			//var textArray:Array = ["1", "100", "100"];
			//var restrictArray:Array = ["0123456789.", "0123456789", "0123456789"];
			//var charArray:Array = [6, 3, 3];
			_textfields = new Vector.<TextField>();
			for (var i:int = 0; i < _len; i++) {
				txt = new TextField();
				txt.selectable = true;
				txt.maxChars = charArray[i];
				txt.defaultTextFormat = new TextFormat('arial', 11, GlobalVariables._whiteColor);
				txt.embedFonts = true;
				txt.x = 0;
				txt.y = i * 15;
				txt.type = "input";
				txt.width = 45;
				txt.height = 18;
				txt.text = textArray[i];
				txt.restrict = restrictArray[i];
				addChild(txt);
				_textfields[i] = txt;
			}
			_drawBackground();
		}
		
		private function _drawBackground():void{
			graphics.clear();
			// get the bounds of the _clip (_clip would be your movieClip)
			var rect:Rectangle = getBounds(this);
			var offset:Number = 1;
			
			// draw a box based on the rect
			with(this.graphics) {
				lineStyle(1.5,0x55AAFF,0.85);
				beginFill(0x000000, 0.85);
				moveTo(rect.x - offset, rect.y - offset);
				lineTo(rect.x + offset + rect.width, rect.y - offset);
				lineTo(rect.x + offset + rect.width, rect.y + offset + rect.height);
				lineTo(rect.x - offset, rect.y + offset + rect.height);
				lineTo(rect.x - offset, rect.y - offset);
				endFill();
			}
		}
		
		//GETTERs related function
		public function get getModifiedData():Array {
			var array:Array = new Array();
			for (var i:int = 0; i < _len; i++) {
				array[i] = _textfields[i].text
			}
			return array;
		}
		
	}

}