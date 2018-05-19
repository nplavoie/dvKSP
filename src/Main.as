package
{
	import flash.display.Bitmap;
    import flash.display.BitmapData;
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
        private var Img:Class;
		private var _img:Sprite;
        private var _texture:BitmapData;
		private var _ui:Ui;
		
		public function Main() 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}

        private function _rafraichir():void
        {
            // Fond
            _img.graphics.clear();
			var mat:Matrix = new Matrix();
			var scaleFactorX:Number = stage.stageWidth / _texture.width, scaleFactorY:Number = stage.stageHeight / _texture.height;
			mat.scale(scaleFactorX,scaleFactorY);
            _img.graphics.beginBitmapFill(_texture,mat,true);
            _img.graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
			
			//envoi les dimensions du Stage -> public static
			GlobalVariables.stageW = stage.stageWidth;
			GlobalVariables.stageH = stage.stageHeight;
        }
        
        /* EVENTS */
        
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			addEventListener(MouseEvent.RIGHT_CLICK, function ():void{});
			// entry point
			
			// Configuration de la scène
			stage.align = StageAlign.TOP_LEFT;
            stage.scaleMode = StageScaleMode.EXACT_FIT;
			stage.displayState = StageDisplayState.NORMAL;
            
            // Polices embarquées
            EmbedFonts.init();
            
			// Fond
            _img = new Sprite();
            addChild(_img);
            
            // Texture du fond
            _texture = (new Img() as Bitmap).bitmapData;
			
			// On met à jour la position des particules et la texture de fond pour la première fois
            _rafraichir();
            
            // Puis lorsque la scène est redimensionnée
            stage.addEventListener(Event.RESIZE, _onStageResize);
            
            // Gestion du clavier
            stage.addEventListener(KeyboardEvent.KEY_UP, _onKeyUp);
			
			//stage.stageWidth,stage.stageHeight
            _ui = new Ui();
            addChild(_ui);
			
        }
	
		private function _onStageResize(event:Event):void
        {
            _rafraichir();
        }
        
        private function _onKeyUp(event:KeyboardEvent):void
        {
			if (event.keyCode == Keyboard.ESCAPE) _ui.exitLinkMode();
			//else if (event.keyCode == Keyboard.O) _ui.openFile()
			//else if (event.keyCode == Keyboard.S) _ui.save();
			
			/*if (event.keyCode == Keyboard.A) _ui.addStage();
			else if (event.keyCode == Keyboard.C) _ui.toggleCondition();
			else if (event.keyCode == Keyboard.D) _ui.removeStage();
			else if (event.keyCode == Keyboard.L) _ui.toggleLinkMode();
			else if (event.keyCode == Keyboard.O) _ui.openFile();
			else if (event.keyCode == Keyboard.S) _ui.saveData();
			else if (event.keyCode == Keyboard.U) _ui.deleteLink();
			else if (event.keyCode == Keyboard.V) _ui.toggleVerbose();
			else if (event.keyCode == Keyboard.ENTER) _ui.calculateDv();
			else if (event.keyCode == Keyboard.SPACE) _ui.restart();
			else if (event.keyCode > 48 && event.keyCode < 58) _ui.setImpactSpeed(event.keyCode);*/
		}
    }
	
}