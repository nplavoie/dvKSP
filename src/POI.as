package 
{
	import flash.display.Sprite;
	/**
	 * ...
	 * @author Nicolas Philippe Lavoie
	 */
	public class POI extends Sprite
	{
		public var title:String, xRef:Number, yRef:Number, label:String, value:Number, units:String, label2:String = "", value2:Number = 0, units2:String = "", label3:String = "", value3:Number = 0, units3:String = "";
		
		public function POI(data:Array, color:uint, size:int) 
		{
			title = data[0];
			xRef = Math.round(data[1] * 10) / 10;
			yRef = Math.round(data[2] * 10) / 10;
			label = data[3];
			value = Math.round(data[4] * 10) / 10;
			units = data[5];
			if (data.length > 6) {
				label2 = data[6];
				value2 = Math.round(data[7] * 10) / 10;
				units2 = data[8];
			}
			if (data.length > 9) {
				label3 = data[9];
				value3 = Math.round(data[10] * 10) / 10;
				units3 = data[11];
			}
			_draw(color, size);
		}
		
		private function _draw(color:uint, size:int):void {
			graphics.beginFill(color, 1);
			graphics.drawCircle(0, 0, size);
			graphics.endFill();
		}
		
	}

}