package 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

	/**
	 * ...
	 * @author Nicolas Philippe Lavoie
	 */
	public class Log extends Sprite
	{
		public static var setText:String;
		private var _log:TextField;
		
		public function Log() 
		{
			_log = new TextField();
			_log.selectable = true;
            _log.autoSize = TextFieldAutoSize.LEFT;
            _log.mouseEnabled = false;
			_log.defaultTextFormat = new TextFormat('arial', 11, GlobalVariables._defaultColor);
            _log.embedFonts = true;
			_log.x = 0;
			_log.y = 0;
			addChild(_log);
			
			EventManager.addEventListener('updateLog', function():void{_log.text = setText});
			EventManager.addEventListener('appendLog', function():void{_log.appendText(setText)});
		}
		
		

	}

}