package 
{
	import flash.display.Sprite;
	import flash.geom.Transform;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.ByteArray;
	import flash.net.registerClassAlias;

	/**
	 * ...
	 * @author Nicolas Philippe Lavoie
	 */
	public class GlobalFunctions 
	{
		
		public function GlobalFunctions() 
		{
			
		}
		
		public static function cloneVecArray( source:Vector.<Array> ):Vector.<Array>
		{
			var toClone:Vector.<Array> = new Vector.<Array>();
			var cloned:Vector.<Array>;
			var ba:ByteArray = new ByteArray();
			registerClassAlias("Array", Array);
			toClone = source;
			ba.writeObject(toClone);
			ba.position = 0;
			cloned = ba.readObject() as Vector.<Array>;
			return cloned;
		}
		
		public static function max(array:Array):Number {
			var len:int = array.length;
			var max:Number = array[0];
			for (var i:int = 1; i < len; i++) {
				if (array[i] > max) max = array[i];
			}
			return max;
		}
		
		public static function sumArray(array:Array):Number {
			var len:int = array.length;
			var sum:Number = 0;
			for (var i:int = 0; i < len; i++) {
				sum += array[i];
			}
			return sum;
		}
		
		public static function medianBurnPoint(arrayA:Array,sumA:Number):Number {
			var sum:Number = 0;
			var i:int = 0;
			sumA *= 0.5;
			while (sum <= sumA) {
				sum += arrayA[i];
				i++;
			}
			return i;
		}
		
		public static function divideEachElementsInArrays(array0:Array,array1:Array):Array {
			var len:int = array0.length;
			var array:Array = new Array();
			if (len != array1.length) return null

			for (var i:int = 0; i < len; i++) {
				if (array1[i] > 0) array[i] = array0[i] / array1[i];
				else array[i] = 0;
			}
			return array;
		}
	
		public static function removeAllChildren(sprite:Sprite):void {
			while (sprite.numChildren > 0) {
				sprite.removeChildAt(sprite.numChildren - 1);
			}
		}
			
		public static function Obj2Array(object:Object):Array {
			var dataArray:Array = new Array(), indexArray:Array = ["payload", "mass_LOX", "mass_LF", "mass_SF", "mass_MP", "mass_Xe", "thrust_atm", "thrust_atm2", "thrust_vac", "isp_atm", "isp_atm2", "isp_vac",  "fuel_factor", "thrust_factor"];
			
			dataArray[0] = int(object.type);
			dataArray[1] = String(object.label);
			if (object.qty == null) dataArray[2] = int(1) else dataArray[2] = object.qty;
			for (var i:int = 0; i < 17; i++){
				if (isNaN(Number(object[indexArray[i]]))) dataArray[i + 3] = 0;
				else dataArray[i+3] = Number(object[indexArray[i]])
			}
			return dataArray;
		}
		
		public static function Array2Obj(array:Array):Object {
			var object:Object = new Object(), indexArray:Array = ["type", "label", "qty", "payload", "mass_LOX", "mass_LF", "mass_SF", "mass_MP", "mass_Xe", "thrust_atm", "thrust_atm2", "thrust_vac", "isp_atm", "isp_atm2", "isp_vac",  "fuel_factor", "thrust_factor"];
			
			for (var i:int = 0; i < 17; i++){
				object[indexArray[i]] = array[i];
			}
			
			return object;
		}
			
	}

}