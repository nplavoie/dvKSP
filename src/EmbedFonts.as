package
{
    import flash.text.Font;
    
    /**
     * Gestionnaire des polices de caractères embarquées.
     * Pour ajouter une police, placer ces fichiers dans le dossier lib/fonts (par exemple : lib/fonts/verdana.ttf), incluez-la dans la classe EmbedFonts ainsi :
     * [Embed(source='../lib/fonts/verdana.ttf',fontName='Fverdana',fontWeight="normal",embedAsCFF=false)]
     * private static var F_VERDANA:Class;
     * puis enregistrez-la dans la méthode init() ainsi :
     * Font.registerFont(F_VERDANA);
     * @author Guillaume CHAU
     */
    public class EmbedFonts
    {
        
        // Incorporation des polices de caractères
        
        ///// Arial
        // Normal
        [Embed(source='../lib/fonts/arial.ttf',fontName='arial',fontWeight="normal",embedAsCFF=false)]
        private static var F_ARIAL:Class;
        // Gras
        [Embed(source='../lib/fonts/arialbd.ttf',fontName='arial',fontWeight="bold",embedAsCFF=false)]
        private static var F_ARIAL_BOLD:Class;
		
		///// Corbel
        // Normal
        [Embed(source='../lib/fonts/corbel.ttf',fontName='corbel',fontWeight="normal",embedAsCFF=false)]
        private static var F_CORBEL:Class;
        // Gras
        [Embed(source='../lib/fonts/corbelb.ttf',fontName='corbel',fontWeight="bold",embedAsCFF=false)]
        private static var F_CORBEL_BOLD:Class;
        
        /**
         * Initialisation des polices de caractères. A appeler une fois au lancement de l'application, afin que les polices soient prises en compte.
         */
        public static function init():void
        {
            // Enregistrement des polices de caractères
            
            Font.registerFont(F_ARIAL);
            Font.registerFont(F_ARIAL_BOLD);
			Font.registerFont(F_CORBEL);
            Font.registerFont(F_CORBEL_BOLD);
        }
    
    }

}