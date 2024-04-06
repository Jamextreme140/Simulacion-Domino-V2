import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxAxes;
import flixel.util.FlxColor;

class ResultState extends FlxSubState
{
	var jugadoresGanados:PlayerList;
	var info:FlxText;
	var bars:Array<FlxSprite>;

	var pr:Float = 0;

	public function new(players:PlayerList)
	{
		super(FlxColor.fromRGB(0, 0, 0, 128));
		jugadoresGanados = players;
	}

	override function create()
	{
		super.create();

		var text = new FlxText(430, 20);
		text.text = "Resultados Finales";
		text.color = FlxColor.BLUE;
		text.size = 36;
		text.setBorderStyle(FlxTextBorderStyle.SHADOW, FlxColor.CYAN, 3);

		info = new FlxText();
		info.text = 'Jugadas ganadas: 
        \nJugador 1: ${jugadoresGanados.player1}
        \nJugador 2: ${jugadoresGanados.player2}
        \nJugador 3: ${jugadoresGanados.player3}
        \nJugador 4: ${jugadoresGanados.player4}';
		info.size = 24;
		info.screenCenter();

		pr = jugadoresGanados.player1 + jugadoresGanados.player2 + jugadoresGanados.player3 + jugadoresGanados.player4;
		// 60, 670 | w: 600 max.
		bars = new Array();
		for (i in 0...4)
		{
			var bar = new FlxSprite(70 * (i + 1) + 30, 600).makeGraphic(80, 1);
			bar.color = FlxG.random.color();
			bar.screenCenter(FlxAxes.Y);
			bars.push(bar);
		}

		bars[0].setGraphicSize(80, 600 * (jugadoresGanados.player1 / pr));
		bars[1].setGraphicSize(80, 600 * (jugadoresGanados.player2 / pr));
		bars[2].setGraphicSize(80, 600 * (jugadoresGanados.player3 / pr));
		bars[3].setGraphicSize(80, 600 * (jugadoresGanados.player4 / pr));

		var closebtn = new FlxButton(0, 680, "Cerrar", () ->
		{
			close();
		});
		closebtn.x = text.x + text.height;

		add(text);
		add(info);
		for (j in bars)
		{
			add(j);
		}
		add(closebtn);
	}
}

typedef PlayerList =
{
	player1:Int,
	player2:Int,
	player3:Int,
	player4:Int,
	tie:Int
}
