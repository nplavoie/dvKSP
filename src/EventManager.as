package {
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	public class EventManager {
			
		private static var dispatcher:EventDispatcher = new EventDispatcher();
		
		public function EventManager():void {
			throw new Error("EventManager is a Singleton");
		}
		
		public static function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void {
			dispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}
		public static function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void {
			dispatcher.removeEventListener(type, listener, useCapture);
		}
		public static function dispatchEvent(event:Event):Boolean {
			return dispatcher.dispatchEvent(event);
		}
		public static function hasEventListener(type:String):Boolean {
			return dispatcher.hasEventListener(type);
		}
 
	}
	
}