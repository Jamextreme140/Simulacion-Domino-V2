package;

import flixel.FlxGame;
import openfl.display.Sprite;

class Main extends Sprite
{
	var game = {
		width: 1280,
		height: 720,
		initState: states.PlayState,
		framerate: 60,
		skipSplash: #if DEBUG true #else false #end,
		startFullscreen: false
	};

	public function new()
	{
		super();

		#if ALLOW_MODDING
		modding.ModHandler.loadMods();
		#end

		addChild(new FlxGame(game.width, game.height, game.initState, game.framerate, game.framerate, game.skipSplash, game.startFullscreen));
	}
}
