package
{
	import flash.display.Sprite;
	
	import org.flixel.FlxGame;
	import org.flixel.FlxG;
	
	
	[SWF(width="600", height="600", backgroundColor="#000000")]
	[Frame(factoryClass="Preloader")]
	
	public class MyFirstRogueLike extends FlxGame
	{
		public function MyFirstRogueLike()
		{
			super( 600, 600, PlayState );
		}
	}
}