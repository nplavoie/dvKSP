package 
{
	/**
	 * ...
	 * @author Nicolas Philippe Lavoie
	 */
	public class EmbedIcons 
	{
		
/*		{label:"Equipement", data:1}, 
		{label:"Tank (LOX/LF)", data:2 },
		{label:"Tank (Monopro)", data:3 },
		{label:"Tank (Xenon)", data:4 },
		{label:"Engine (LOX/LF)", data:5 },
		{label:"Engine (SRB)", data:6 },
		{label:"Engine (Monopro)", data:7 },
		{label:"Engine (Xenon)", data:8 },
		{label:"Engine-tank (LOX/LF)", data:9 }*/
			
		//Background Bitmap for Stages Class
		[Embed(source = "../lib/img/icon.ksp.png")]
		public static var ImgStages:Class;
		
		//Background Bitmap for Parts Class (type Payload)
		[Embed(source = "../lib/img/_payload.png")]
		public static var ImgParts1:Class;
		
		//Background Bitmap for Parts Class (type Fuel + LOX tank)
		[Embed(source = "../lib/img/_tank.flox.png")]
		public static var ImgParts2:Class;
		
		//Background Bitmap for Parts Class (type Monopropellant tank)
		[Embed(source = "../lib/img/_tank.m.png")]
		public static var ImgParts3:Class;
		
		//Background Bitmap for Parts Class (type Xenon tank)
		[Embed(source = "../lib/img/_tank.x.png")]
		public static var ImgParts4:Class;
		
		//Background Bitmap for Parts Class (type Fuel + LOX Engine)
		[Embed(source = "../lib/img/_engine.flox.png")]
		public static var ImgParts5:Class;
		
		//Background Bitmap for Parts Class (type Solid Booster)
		[Embed(source = "../lib/img/_srb.png")]
		public static var ImgParts6:Class;
		
		//Background Bitmap for Parts Class (type Monopropellant Engine)
		[Embed(source = "../lib/img/_engine.m.png")]
		public static var ImgParts7:Class;
		
		//Background Bitmap for Parts Class (type Xenon Engine)
		[Embed(source = "../lib/img/_engine.x.png")]
		public static var ImgParts8:Class;
		
		//Background Bitmap for Parts Class (type Liquid Engine-Tank Booster)
		[Embed(source = "../lib/img/_engine.tank.flox.png")]
		public static var ImgParts9:Class;
		
		//Background Bitmap for Link Mode
		[Embed(source = "../lib/img/icon.remove.png")]
		public static var ImgDel:Class;
		
		//Background Bitmap for Insert Stage
		[Embed(source = "../lib/img/icon.insert.png")]
		public static var ImgIns:Class;
		
		//Background Bitmap for Parachute
		[Embed(source = "../lib/img/icon.para.png")]
		public static var ImgPara:Class;
		
		//Background Bitmap for Copy
		[Embed(source = "../lib/img/icon.copy.png")]
		public static var ImgCopy:Class;
		
		//Background Bitmap for Set
		[Embed(source = "../lib/img/icon.apply.png")]
		public static var ImgApply:Class;
		
		//Background Bitmap for Set
		[Embed(source = "../lib/img/icon.apply.all.png")]
		public static var ImgApplyAll:Class;
		
		//Background Bitmap for Link mode
		[Embed(source = "../lib/img/icon.link.png")]
		public static var ImgLink:Class;
		
		//Background Bitmap for Save file
		[Embed(source = "../lib/img/icon.save.png")]
		public static var ImgSave:Class;
		
		//Background Bitmap for Save file
		[Embed(source = "../lib/img/icon.load.png")]
		public static var ImgLoad:Class;
		
		//Background Bitmap for Simulate
		[Embed(source = "../lib/img/icon.simulate.png")]
		public static var ImgSim:Class;
		
		public function EmbedIcons() 
	}

}