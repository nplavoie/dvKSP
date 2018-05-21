package
{
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageDisplayState;
    import flash.display.StageScaleMode;
    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.geom.Matrix;
    import flash.ui.Keyboard;
    import EmbedIcons;
    import Constantes;
	
	/**
	 * ...
	 * @author Nicolas Philippe Lavoie
	 */
	public class Main extends Sprite
	{
		
		[Embed(source = "../lib/img/background.png")]
       		private var Img:Class, _img:Shape, _texture:BitmapData, _ui:Ui;
	
		public function Main() 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}

		private function _refresh():void
		{
		    // resize background picture
		    _img.graphics.clear();
		    var mat:Matrix = new Matrix();
		    var scaleFactorX:Number = stage.stageWidth / _texture.width, scaleFactorY:Number = stage.stageHeight / _texture.height;
		    mat.scale(scaleFactorX,scaleFactorY);
		    _img.graphics.beginBitmapFill(_texture,mat,true);
		    _img.graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);

		    //send dimensions of stage to global variables
		    GlobalVariables.stageW = stage.stageWidth;
		    GlobalVariables.stageH = stage.stageHeight;
		}
        
		/* EVENTS */
        
		private function init(e:Event = null):void 
		{
			// stage parameters
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.EXACT_FIT;
			stage.displayState = StageDisplayState.NORMAL;
            
			// EmbedFonts initialization
			EmbedFonts.init();
            
			// Define sprite for background texture
			_img = new Shape();
			addChild(_img);
            
			// Set empty texture as background
			_texture = (new Img() as Bitmap).bitmapData;
			
			// Apply bitmapData as texture
			_refresh();
            
			_ui = new Ui();
			addChild(_ui);
			
			// Events
			removeEventListener(Event.ADDED_TO_STAGE, init);
			addEventListener(MouseEvent.RIGHT_CLICK, function ():void{});
			stage.addEventListener(Event.RESIZE, _onStageResize);
  			stage.addEventListener(KeyboardEvent.KEY_UP, _onKeyUp);
		}
	
		private function _onStageResize(event:Event):void {
			_refresh();
		}
        
		private function _onKeyUp(event:KeyboardEvent):void {
			if (event.keyCode == Keyboard.ESCAPE) _ui.exitLinkMode();
		}
	}
}
