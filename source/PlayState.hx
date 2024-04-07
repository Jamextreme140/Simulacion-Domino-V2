package;

import Ficha;
import Utils;
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
	var playerLabel:Array<FlxText> = [];
	var gameLabel:FlxText;
	var elapsedGame:FlxText;
	var first:Bool = true;

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
	}

	function comenzarJuego(n:Int)
	{
		first = false;
		var jugadoresGanados = {
			player1: 0,
			player2: 0,
			player3: 0,
			player4: 0,
			tie: 0
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
			var arr = [0, 0, 0, 0];
			for (i in players)
			{
				for (j in i)
				{
					if (j != null)
					{
						if (i == player1)
							arr[0] += j.points;
						else if (i == player2)
							arr[1] += j.points;
						else if (i == player3)
							arr[2] += j.points;
						else if (i == player4)
							arr[3] += j.points;
					}
				}
			}
			print(arr.toString());
			var l = arr[0];
			var p = 1;
			for (k in 1...arr.length)
			{
				if (arr[k] < l)
				{
					l = arr[k];
					p = k + 1;
				}
			}
			return (Utils.arrayDuplicates(arr)) ? -1 : p;
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
			elapsedGame.text = '#${t.elapsedLoops}';
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
			t.active = false;
			new FlxTimer().start(0.2, function(tp:FlxTimer)
			{
				for (spr in playerLabel)
				{
					spr.color = FlxColor.WHITE;
				}
				gameLabel.text = '';
				gameLabel.color = FlxColor.WHITE;

				tamanio = 44;
				switch (jugador)
				{
					case 1: // Jugador 1
						playerLabel[0].color = FlxColor.GREEN;
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
								tamanio = 30;
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
								gameLabel.text = "Jugador 1 Gana";
								termina = !termina;
								t.active = true;
								tp.cancel();
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
								tamanio = 30;
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
								gameLabel.text = "Jugador 1 Gana";
								termina = !termina;
								t.active = true;
								tp.cancel();
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
						playerLabel[1].color = FlxColor.GREEN;
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
								tamanio = 30;
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
								gameLabel.text = "Jugador 2 Gana";
								termina = !termina;
								t.active = true;
								tp.cancel();
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
								tamanio = 30;
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
								gameLabel.text = "Jugador 2 Gana";
								termina = !termina;
								t.active = true;
								tp.cancel();
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
						playerLabel[2].color = FlxColor.GREEN;
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
								tamanio = 30;
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
								gameLabel.text = "Jugador 3 Gana";
								termina = !termina;
								t.active = true;
								tp.cancel();
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
								tamanio = 30;
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
								gameLabel.text = "Jugador 3 Gana";
								termina = !termina;
								t.active = true;
								tp.cancel();
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
						playerLabel[3].color = FlxColor.GREEN;
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
								tamanio = 30;
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
								gameLabel.text = "Jugador 4 Gana";
								termina = !termina;
								t.active = true;
								tp.cancel();
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
								tamanio = 30;
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
								gameLabel.text = "Jugador 4 Gana";
								termina = !termina;
								t.active = true;
								tp.cancel();
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
					print(w);
					switch (w)
					{
						case 1:
							print("Jugador 1 Gana");
							gameLabel.text = "Jugador 1 Gana";
							jugadoresGanados.player1++;
						case 2:
							print("Jugador 2 Gana");
							gameLabel.text = "Jugador 2 Gana";
							jugadoresGanados.player2++;
						case 3:
							print("Jugador 3 Gana");
							gameLabel.text = "Jugador 3 Gana";
							jugadoresGanados.player3++;
						case 4:
							print("Jugador 4 Gana");
							gameLabel.text = "Jugador 4 Gana";
							jugadoresGanados.player4++;
						case _:
							print("Empate");
							gameLabel.text = "Empate";
							gameLabel.color = FlxColor.RED;
							jugadoresGanados.tie++;
					}
					t.active = true;
					tp.cancel();
				}
				if (t.finished && tp.finished)
					openResultState(jugadoresGanados);
			}, 0);
			print("Termina");
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

	function buscarFicha(arr:Array<Ficha>, s:Int)
	{
		for (i in arr)
		{
			if (i.North == s || i.South == s)
				return arr.indexOf(i);
		}
		return -1;
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

	function setLabels()
	{
		playerLabel.push(new FlxText(player1XY.x, player1XY.y - 20, 0, "Jugador 1", 14));
		playerLabel.push(new FlxText(player2XY.x - 300, player2XY.y, 0, "Jugador 2", 14));
		playerLabel.push(new FlxText(player3XY.x - 30, player3XY.y - 20, 0, "Jugador 3", 14));
		playerLabel.push(new FlxText(player4XY.x, player4XY.y - 50, 0, "Jugador 4", 14));
		for (spr in playerLabel)
		{
			add(spr);
		}
	}

	function onButtonClicked()
	{
		print("Starting...");
		if (!first)
		{
			reset();
			elapsedGame.text = '';
		}
		Simulacion(Std.parseInt(textfield.text));
	}

	override public function create()
	{
		super.create();
		add(setTitle("Domino", /*550, 20,*/ 48));
		add(setText("¿Cuantos juegos quieres jugar?", 20, 650));
		add(setTextField(20, 675));
		add(setButton("Simular", 150, 680));
		setLabels();
		gameLabel = new FlxText(1020, 650, 0, '', 18);
		add(gameLabel);
		elapsedGame = new FlxText(5, 5, 0, '', 20);
		elapsedGame.color = FlxColor.GRAY;
		add(elapsedGame);
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
