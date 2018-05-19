package  
{
    public class Constantes 
    {
		public static var precision:Number = 1000;
		public static var precision2:Number = 100;
		public static var P2D:Number = 1.2230948554874;
		public static var ISPg0:Number = 9.80665;
		//label, g0, GM constant, planet radius (m), sideral rotational velocity (m/s), atmosphere limit (m), scale height, air density at ground (kg/m^3)
		public static var kerbin:Array = ["kerbin", 9.81, Number(3.5316E12), 600000, 174.94, 70000, 5600, 1.225];
		public static var laythe:Array = ["laythe", 7.85, Number(1.962E12), 500000, 59.297, 50000, 8000, 0.9188];
		public static var duna:Array = ["duna", 2.94, Number(3.0136321E11), 320000, 30.688, 50000, 5700, 0.1361];
		public static var eve:Array = ["eve", 16.7, Number(8.1717302E12), 700000, 54.636, 90000, 7200, 2.401];
		public static var gilly:Array = ["gilly", 0.049, Number(8289449.8), 13000, 2.8909];
		public static var ike:Array = ["ike", 1.10, Number(1.8568369E10), 130000, 12.467];
		public static var mun:Array = ["mun", 1.63, Number(6.5138398E10), 200000, 9.0416, 6200, 0, 0];
		public static var minmus:Array = ["minmus", 0.491, Number(1.7658000E9), 60000, 9.3315, 5800, 0, 0];
		
    }
}