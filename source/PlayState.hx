package;

import Ficha;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.ui.FlxUIInputText;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxAxes;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxTimer;
import lime.app.Application;
#if cpp
import cpp.vm.Gc;
#elseif hl
import hl.Gc;
#end

class PlayState extends FlxState
{
	var textfield:FlxUIInputText;
	var button:FlxButton;
	var timer:FlxTimer = new FlxTimer();

	/**
	 * Jugador izquierda
	 */
	var player1:Array<Ficha> = new Array();

	var player1XY = {x: 25, y: 130, angle: 90};

	/**
	 * Jugador arriba
	 */
	var player2:Array<Ficha> = new Array();

	var player2XY = {x: 475, y: 10, angle: 180};

	/**
	 * Jugador derecha
	 */
	var player3:Array<Ficha> = new Array();

	var player3XY = {x: 1210, y: 130, angle: -90};

	/**
	 * Jugador abajo
	 */
	var player4:Array<Ficha> = new Array();

	var player4XY = {x: 475, y: 610, angle: 0};

	// Fichas izquierda y derecha de la mesa
	var derecha:Array<Ficha> = new Array();
	var izquierda:Array<Ficha> = new Array();

	/**
	 * Representacion de los 4 jugadores
	 */
	var players(get, never):Array<Array<Ficha>>;

	public function new()
	{
		super();
	}

	function Simulacion(n:Int)
	{
		if (n < 4)
		{
			Application.current.window.alert("Error: El numero de veces debe ser igual o mayor a 4, para una mejor precision.", "Limite inferior no permitido");
			return;
		}
		comenzarJuego(n);
		/*
			new FlxTimer().start(1, function(tmr:FlxTimer)
			{
				reset();
			});
		 */
	}

	function comenzarJuego(n:Int)
	{
		var jugadoresGanados = {
			player1: 0,
			player2: 0,
			player3: 0,
			player4: 0
		};
		var ultimaFicha1 = {
			x: 0.0,
			y: 0.0,
			n: 0,
			s: 0,
			angle: -90
		};
		var ultimaFicha2 = {
			x: 0.0,
			y: 0.0,
			n: 0,
			s: 0,
			angle: -90
		};
		// var primeraJugada:Bool = true;
		var pass:Int = 0;
		var tamanio = 44;
		var jugador:Int = 0;

		// Ficha izquierda
		function setUltimaFicha1(x:Float, y:Float, n:Int, s:Int)
		{
			ultimaFicha1.x = x;
			ultimaFicha1.y = y;
			ultimaFicha1.n = n;
			ultimaFicha1.s = s;
		}
		// Ficha derecha
		function setUltimaFicha2(x:Float, y:Float, n:Int, s:Int)
		{
			ultimaFicha2.x = x + 22;
			ultimaFicha2.y = y;
			ultimaFicha2.n = n;
			ultimaFicha2.s = s;
		}

		function calcularPuntos()
		{
			var arr = [1 => 0, 2 => 0, 3 => 0, 4 => 0];
			for (i in players)
			{
				for (j in i)
				{
					if (j != null)
					{
						if (i == player1)
							arr.set(1, arr.get(1) + j.points);
						else if (i == player2)
							arr.set(2, arr.get(2) + j.points);
						else if (i == player3)
							arr.set(3, arr.get(3) + j.points);
						else if (i == player4)
							arr.set(4, arr.get(4) + j.points);
					}
				}
			}
			var h = 0;
			var p = 0;
			for (k => v in arr)
			{
				if (v > h)
				{
					h = v;
					p = k;
				}
			}
			return p;
		}

		function juego(t:FlxTimer)
		{
			if (t.elapsedLoops > 0)
			{
				reset();
				setUltimaFicha1(0, 0, 0, 0);
				setUltimaFicha2(0, 0, 0, 0);
				jugador = 0;
				pass = 0;
				tamanio = 44;
			}
			print('Juego #${t.elapsedLoops}');
			var termina:Bool = false;
			// Juego
			repartirFichas();
			// Primera jugada
			var found:Bool = false;
			while (!found)
			{
				jugador++;
				print(jugador);
				for (j in players[jugador - 1])
				{
					if (j.North == 6 && j.South == 6)
					{
						derecha.push(j);
						j.scale.set(0.1, 0.1);
						j.updateHitbox();
						j.screenCenter();
						j.angle = 0;
						players[jugador - 1].remove(j);
						setUltimaFicha1(j.x, j.y, j.North, j.South);
						setUltimaFicha2(j.x, j.y, j.North, j.South);
						print('Jugador ${jugador} tiene mula de 6');
						jugador++;
						found = true;
						break;
					}
				}
			}
			while (!termina)
			{
				tamanio = 44;
				print('-${jugador}-');
				switch (jugador)
				{
					case 1: // Jugador 1
						var indice = buscarFicha(player1, ultimaFicha1.s);
						print(jugador + ' - ' + indice);
						if (indice != -1)
						{
							// Poner a la izquierda
							if (player1[indice].South == ultimaFicha1.s)
								player1[indice].angle = -90;
							// Si es mula, la coloca parada
							if (player1[indice].esMula())
							{
								player1[indice].angle = 0;
								tamanio = 22;
							}
							player1[indice].scale.set(0.1, 0.1);
							player1[indice].updateHitbox();
							player1[indice].setPosition(ultimaFicha1.x - tamanio, ultimaFicha1.y);
							player1[indice].screenCenter(FlxAxes.Y);
							if (player1[indice].South == ultimaFicha1.s)
								setUltimaFicha1(player1[indice].x, player1[indice].y, player1[indice].South, player1[indice].North);
							else
								setUltimaFicha1(player1[indice].x, player1[indice].y, player1[indice].North, player1[indice].South);
							izquierda.push(player1[indice]);
							player1.remove(player1[indice]);
							if (player1.length <= 0)
							{
								jugadoresGanados.player1++;
								// break;
								print("Jugador 1 Gana");
								termina = !termina;
							}
							pass = 0;
						}
						else if ((indice = buscarFicha(player1, ultimaFicha2.s)) != -1)
						{
							print(jugador + ' - ' + indice);
							// Poner a la derecha
							if (player1[indice].North == ultimaFicha2.s)
								player1[indice].angle = -90;
							// Si es mula, la coloca parada
							if (player1[indice].esMula())
							{
								player1[indice].angle = 0;
								tamanio = 22;
							}
							player1[indice].scale.set(0.1, 0.1);
							player1[indice].updateHitbox();
							player1[indice].setPosition(ultimaFicha2.x + tamanio, ultimaFicha2.y);
							player1[indice].screenCenter(FlxAxes.Y);
							if (player1[indice].North == ultimaFicha2.s)
								setUltimaFicha2(player1[indice].x, player1[indice].y, player1[indice].North, player1[indice].South);
							else
								setUltimaFicha2(player1[indice].x, player1[indice].y, player1[indice].South, player1[indice].North);
							derecha.push(player1[indice]);
							player1.remove(player1[indice]);
							if (player1.length <= 0)
							{
								jugadoresGanados.player1++;
								// break;
								print("Jugador 1 Gana");
								termina = !termina;
							}
							pass = 0;
						}
						else
						{
							// Pasa
							pass++;
						}
						jugador++;
					case 2: // Jugador 2
						var indice = buscarFicha(player2, ultimaFicha1.s);
						print(jugador + ' - ' + indice);
						if (indice != -1)
						{
							// Poner a la izquierda
							if (player2[indice].South == ultimaFicha1.s)
								player2[indice].angle = -90;
							else
								player2[indice].angle = 90;
							// Si es mula, la coloca parada
							if (player2[indice].esMula())
							{
								player2[indice].angle = 0;
								tamanio = 22;
							}
							player2[indice].scale.set(0.1, 0.1);
							player2[indice].updateHitbox();
							player2[indice].setPosition(ultimaFicha1.x - tamanio, ultimaFicha1.y);
							player2[indice].screenCenter(FlxAxes.Y);
							if (player2[indice].South == ultimaFicha1.s)
								setUltimaFicha1(player2[indice].x, player2[indice].y, player2[indice].South, player2[indice].North);
							else
								setUltimaFicha1(player2[indice].x, player2[indice].y, player2[indice].North, player2[indice].South);
							izquierda.push(player2[indice]);
							player2.remove(player2[indice]);
							if (player2.length <= 0)
							{
								jugadoresGanados.player2++;
								// break;
								print("Jugador 2 Gana");
								termina = !termina;
							}
							pass = 0;
						}
						else if ((indice = buscarFicha(player2, ultimaFicha2.s)) != -1)
						{
							print(jugador + ' - ' + indice);
							// Poner a la derecha
							if (player2[indice].North == ultimaFicha2.s)
								player2[indice].angle = -90;
							else
								player2[indice].angle = 90;
							// Si es mula, la coloca parada
							if (player2[indice].esMula())
							{
								player2[indice].angle = 0;
								tamanio = 22;
							}
							player2[indice].scale.set(0.1, 0.1);
							player2[indice].updateHitbox();
							player2[indice].setPosition(ultimaFicha2.x + tamanio, ultimaFicha2.y);
							player2[indice].screenCenter(FlxAxes.Y);
							if (player2[indice].North == ultimaFicha2.s)
								setUltimaFicha2(player2[indice].x, player2[indice].y, player2[indice].North, player2[indice].South);
							else
								setUltimaFicha2(player2[indice].x, player2[indice].y, player2[indice].South, player2[indice].North);
							derecha.push(player2[indice]);
							player2.remove(player2[indice]);
							if (player2.length <= 0)
							{
								jugadoresGanados.player2++;
								// break;
								print("Jugador 2 Gana");
								termina = !termina;
							}
							pass = 0;
						}
						else
						{
							// Pasa
							pass++;
						}
						jugador++;
					case 3:
						var indice = buscarFicha(player3, ultimaFicha1.s);
						print(jugador + ' - ' + indice);
						if (indice != -1)
						{
							// Poner a la izquierda
							if (player3[indice].South == ultimaFicha1.s)
								player3[indice].angle = -90;
							else
								player3[indice].angle = 90;
							// Si es mula, la coloca parada
							if (player3[indice].esMula())
							{
								player3[indice].angle = 0;
								tamanio = 22;
							}
							player3[indice].scale.set(0.1, 0.1);
							player3[indice].updateHitbox();
							player3[indice].setPosition(ultimaFicha1.x - tamanio, ultimaFicha1.y);
							player3[indice].screenCenter(FlxAxes.Y);
							if (player3[indice].South == ultimaFicha1.s)
								setUltimaFicha1(player3[indice].x, player3[indice].y, player3[indice].South, player3[indice].North);
							else
								setUltimaFicha1(player3[indice].x, player3[indice].y, player3[indice].North, player3[indice].South);
							izquierda.push(player3[indice]);
							player3.remove(player3[indice]);
							if (player3.length <= 0)
							{
								jugadoresGanados.player3++;
								// break;
								print("Jugador 3 Gana");
								termina = !termina;
							}
							pass = 0;
						}
						else if ((indice = buscarFicha(player3, ultimaFicha2.s)) != -1)
						{
							print(jugador + ' - ' + indice);
							// Poner a la derecha
							if (player3[indice].North == ultimaFicha2.s)
								player3[indice].angle = -90;
							else
								player3[indice].angle = 90;
							// Si es mula, la coloca parada
							if (player3[indice].esMula())
							{
								player3[indice].angle = 0;
								tamanio = 22;
							}
							player3[indice].scale.set(0.1, 0.1);
							player3[indice].updateHitbox();
							player3[indice].setPosition(ultimaFicha2.x + tamanio, ultimaFicha2.y);
							player3[indice].screenCenter(FlxAxes.Y);
							if (player3[indice].North == ultimaFicha2.s)
								setUltimaFicha2(player3[indice].x, player3[indice].y, player3[indice].North, player3[indice].South);
							else
								setUltimaFicha2(player3[indice].x, player3[indice].y, player3[indice].South, player3[indice].North);
							derecha.push(player3[indice]);
							player3.remove(player3[indice]);
							if (player3.length <= 0)
							{
								jugadoresGanados.player3++;
								// break;
								print("Jugador 3 Gana");
								termina = !termina;
							}
							pass = 0;
						}
						else
						{
							// Pasa
							pass++;
						}
						jugador++;
					case 4:
						var indice = buscarFicha(player4, ultimaFicha1.s);
						print(jugador + ' - ' + indice);
						if (indice != -1)
						{
							// Poner a la izquierda
							if (player4[indice].South == ultimaFicha1.s)
								player4[indice].angle = -90;
							else
								player4[indice].angle = 90;
							// Si es mula, la coloca parada
							if (player4[indice].esMula())
							{
								player4[indice].angle = 0;
								tamanio = 22;
							}
							player4[indice].scale.set(0.1, 0.1);
							player4[indice].updateHitbox();
							player4[indice].setPosition(ultimaFicha1.x - tamanio, ultimaFicha1.y);
							player4[indice].screenCenter(FlxAxes.Y);
							if (player4[indice].South == ultimaFicha1.s)
								setUltimaFicha1(player4[indice].x, player4[indice].y, player4[indice].South, player4[indice].North);
							else
								setUltimaFicha1(player4[indice].x, player4[indice].y, player4[indice].North, player4[indice].South);
							izquierda.push(player4[indice]);
							player4.remove(player4[indice]);
							if (player4.length <= 0)
							{
								jugadoresGanados.player4++;
								// break;
								print("Jugador 4 Gana");
								termina = !termina;
							}
							pass = 0;
						}
						else if ((indice = buscarFicha(player4, ultimaFicha2.s)) != -1)
						{
							print(jugador + ' - ' + indice);
							// Poner a la derecha
							if (player4[indice].North == ultimaFicha2.s)
								player4[indice].angle = -90;
							else
								player4[indice].angle = 90;
							// Si es mula, la coloca parada
							if (player4[indice].esMula())
							{
								player4[indice].angle = 0;
								tamanio = 22;
							}
							player4[indice].scale.set(0.1, 0.1);
							player4[indice].updateHitbox();
							player4[indice].setPosition(ultimaFicha2.x + tamanio, ultimaFicha2.y);
							player4[indice].screenCenter(FlxAxes.Y);
							if (player4[indice].North == ultimaFicha2.s)
								setUltimaFicha2(player4[indice].x, player4[indice].y, player4[indice].North, player4[indice].South);
							else
								setUltimaFicha2(player4[indice].x, player4[indice].y, player4[indice].South, player4[indice].North);
							derecha.push(player4[indice]);
							player4.remove(player4[indice]);
							if (player4.length <= 0)
							{
								jugadoresGanados.player4++;
								// break;
								print("Jugador 4 Gana");
								termina = !termina;
							}
							pass = 0;
						}
						else
						{
							// Pasa
							pass++;
						}
						jugador++;
					case _:
						jugador = 1;
						// pass++;
				}

				if (pass > 4)
				{
					print("Juego fallido");
					var w = calcularPuntos();
					switch (w)
					{
						case 1:
							print("Jugador 1 Gana");
							jugadoresGanados.player1++;
						case 2:
							print("Jugador 2 Gana");
							jugadoresGanados.player2++;
						case 3:
							print("Jugador 3 Gana");
							jugadoresGanados.player3++;
						case 4:
							print("Jugador 4 Gana");
							jugadoresGanados.player4++;
					}
					break;
				}
			}
			print("Termina");
			if (t.finished)
				openResultState(jugadoresGanados);
		}

		timer.start(0.5, juego, n);
	}

	function reset()
	{
		#if hl
		Gc.enable(true);
		#end
		for (i in players)
		{
			FlxDestroyUtil.destroyArray(i);
			i.splice(0, i.length);
		}
		FlxDestroyUtil.destroyArray(izquierda);
		izquierda.splice(0, izquierda.length);
		FlxDestroyUtil.destroyArray(derecha);
		derecha.splice(0, derecha.length);
		#if cpp
		Gc.run(true);
		#elseif hl
		Gc.major();
		#end
	}

	function repartirFichas()
	{
		var exclude:Array<String> = new Array();
		for (i in players)
		{
			var j = 0;
			while (j < 7)
			{
				var curNorth:Int;
				var n:Int;
				var curSouth:Int;
				var s:Int;
				var north = Math.random();
				var south = Math.random();
				// Ficha-Valor norte
				if (north > 0 && north < 0.14)
					curNorth = 0;
				else if (north > 0.14 && north < 0.29)
					curNorth = 1;
				else if (north > 0.29 && north < 0.43)
					curNorth = 2;
				else if (north > 0.43 && north < 0.57)
					curNorth = 3;
				else if (north > 0.57 && north < 0.71)
					curNorth = 4;
				else if (north > 0.71 && north < 0.86)
					curNorth = 5;
				else
					curNorth = 6;
				// Ficha-Valor sur
				if (south > 0 && south < 0.14)
					curSouth = 0;
				else if (south > 0.14 && south < 0.29)
					curSouth = 1;
				else if (south > 0.29 && south < 0.43)
					curSouth = 2;
				else if (south > 0.43 && south < 0.57)
					curSouth = 3;
				else if (south > 0.57 && south < 0.71)
					curSouth = 4;
				else if (south > 0.71 && south < 0.86)
					curSouth = 5;
				else
					curSouth = 6;

				n = Std.int(Math.max(curNorth, curSouth));
				s = Std.int(Math.min(curNorth, curSouth));

				if (exclude.contains('${n}_${s}'))
					continue;

				exclude.push('${n}_${s}');
				/*
					if (searchNSPerPlayer(Std.string('${n}_${s}')))
						continue;
				 */
				/*
					if (j > 1)
					{
						if (searchNSPerPlayer(Std.string('${n}_${s}')))
							continue;
					}
				 */
				if (i == player1) // Izquierda
					i.push(new Ficha(player1XY.x, player1XY.y + (45 * j), player1XY.angle, n, s));
				else if (i == player2) // Arriba
					i.push(new Ficha(player2XY.x + (45 * j), player2XY.y, player2XY.angle, n, s));
				else if (i == player3) // Derecha
					i.push(new Ficha(player3XY.x, player3XY.y + (45 * j), player3XY.angle, n, s));
				else if (i == player4) // Abajo
					i.push(new Ficha(player4XY.x + (45 * j), player4XY.y, player4XY.angle, n, s));
				add(i[j]);
				j++;
			}
		}
	}

	/*
		function buscarFichaN(arr:Array<Ficha>, n:Int, s:Int)
		{
			for (i in arr)
			{
				if (i.North == s)
					return arr.indexOf(i);
			}
			return -1;
		}

		function buscarFichaS(arr:Array<Ficha>, n:Int, s:Int)
		{
			for (i in arr)
			{
				if (i.South == s)
					return arr.indexOf(i);
			}
			return -1;
		}
	 */
	function buscarFicha(arr:Array<Ficha>, s:Int)
	{
		for (i in arr)
		{
			if (i.North == s || i.South == s)
				return arr.indexOf(i);
		}
		return -1;
	}

	@:noCompletion function buscarMula(x:Ficha)
	{
		for (i in players)
		{
			for (j in i)
			{
				if (j.North == 6 && j.South == 6)
				{
					return i;
				}
			}
		}
		return null;
	}

	/**
	 * Busca la ficha dada en el jugador. 
	 * En caso de no encontrase, devolverá -1.
	 * @param arr Fichas del jugador actual
	 * @param NS Ficha a buscar
	 */
	function searchNS(arr:Array<Ficha>, NS:String)
	{
		for (i in arr)
		{
			if (i.NS == NS)
				return arr.indexOf(i);
		}
		return -1;
	}

	/**
	 * Busca en las fichas de cada jugador
	 * @param v Valor de ficha
	 */
	function searchNSPerPlayer(v:String)
	{
		var arr = [player1, player2, player3, player4];
		for (i in arr)
		{
			if (i != null)
			{
				for (j in i)
				{
					if (j.NS == v)
						return true;
				}
			}
		}
		return false;
	}

	function setTitle(text:String, /* x:Int, y:Int,*/ size:Int)
	{
		var title = new FlxText();
		title.text = text;
		title.color = FlxColor.fromRGB(54, 54, 54);
		title.size = size;
		title.screenCenter();
		return title;
	}

	function setText(text:String, x:Float, y:Float)
	{
		var Text = new FlxText(x, y);
		Text.text = text;
		Text.color = FlxColor.WHITE;
		Text.size = 16;
		return Text;
	}

	function setTextField(x:Float, y:Float)
	{
		textfield = new FlxUIInputText(x, y, 100, null, 16);
		return textfield;
	}

	function setButton(text:String, x:Float, y:Float)
	{
		button = new FlxButton(x, y, text, onButtonClicked);
		return button;
	}

	function onButtonClicked()
	{
		print("Starting...");
		// openResult();
		Simulacion(Std.parseInt(textfield.text));
	}

	override public function create()
	{
		super.create();
		add(setTitle("Domino", /*550, 20,*/ 48));
		add(setText("¿Cuantos juegos quieres jugar?", 20, 650));
		add(setTextField(20, 675));
		add(setButton("Simular", 150, 680));
	}

	override public function update(elapsed:Float)
	{
		if (textfield.hasFocus)
		{
			FlxG.sound.volumeDownKeys = FlxG.sound.volumeUpKeys = FlxG.sound.muteKeys = null;
		}
		else
		{
			FlxG.sound.volumeDownKeys = [MINUS, NUMPADMINUS];
			FlxG.sound.volumeUpKeys = [MINUS, NUMPADPLUS];
			FlxG.sound.muteKeys = [ZERO, NUMPADZERO];
		}

		if (FlxG.keys.pressed.LEFT)
		{
			FlxG.camera.scroll.x -= elapsed * 200;
		}
		else if (FlxG.keys.pressed.RIGHT)
		{
			FlxG.camera.scroll.x += elapsed * 200;
		}
		super.update(elapsed);
	}

	function get_players():Array<Array<Ficha>>
	{
		return [player1, player2, player3, player4];
	}

	function print(v:Dynamic)
	{
		haxe.Log.trace(v, null);
	}

	function openResultState(players:Dynamic)
	{
		openSubState(new ResultState(players));
	}
}
