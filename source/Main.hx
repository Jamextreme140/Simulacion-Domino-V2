package;

import flixel.FlxGame;
import openfl.display.Sprite;

class Main extends Sprite
{
	var game = {
		width: 1280,
		height: 720,
		initState: PlayState,
		framerate: 60,
		skipSplash: false,
		startFullscreen: false
	};

	public function new()
	{
		super();
		addChild(new FlxGame(game.width, game.height, game.initState, game.framerate, game.framerate, game.skipSplash, game.startFullscreen));
	}
}
