package objects;

import flixel.FlxSprite;

class Ficha extends FlxSprite
{
	public var North(get, null):Int;
	public var South(get, null):Int;
	public var NS(get, null):String;
	public var points(get, null):Int;

	var imagepath = "assets/images/";

	public function new(x:Int, y:Int, angle:Int, n:Int, s:Int)
	{
		super(x, y);
		North = /*Std.int(Math.max(n, s))*/ n;
		South = /*Std.int(Math.min(n, s))*/ s;
		init();
		if (angle != 0)
			this.angle = angle;
	}

	function init()
	{
		var sprite = '${NS}.png';
		this.loadGraphic(imagepath + sprite);
		this.scale.set(0.2, 0.2); // 43.8 x 86.8
		this.updateHitbox();
	}

	function get_North():Int
	{
		return North;
	}

	function get_South():Int
	{
		return South;
	}

	public function esMula():Bool
	{
		return North == South;
	}

	function get_NS():String
	{
		return Std.string('${North}_${South}');
	}

	public override function destroy()
	{
		North = South = 0;
		NS = null;
		super.destroy();
	}

	function get_points():Int
	{
		return (North == 0 && South == 0) ? 50 : North + South;
	}
}
