extends Control

var characters = [];
var num_living_characters;

var can_move = false;
var can_place_bombs = false;
var round_ending = false;
var round_ended = false;

onready var ui_layer = get_node("UILayer");
onready var game_area = get_node("GameArea");
onready var game_board = game_area.get_node("GameBoard");
onready var player_scoreboard = ui_layer.get_node("PlayerScoreboard");
onready var anim = get_node("AnimationPlayer");

onready var char_scn = load("res://game/character/character.tscn");
onready var playercontroller_scn = load("res://game/controllers/playercontroller/playercontroller.tscn");

func _ready():
	spawn_players();
	begin_round_start();
	pass

func place_player(player):
	var new_character = char_scn.instance();
	var new_pos = game_board.spawn_points[player.player_num - 1].get_global_pos();
	
	new_character.player_num = player.player_num;
	new_character.set_global_pos(new_pos);
	game_area.add_child(new_character);
	
	var new_controller;
	
	if (player.control_type == game.ControlType.PLAYER_CONTROLLER):
		new_controller = playercontroller_scn.instance();
		new_controller.player_num = player.player_num;
	
	new_controller.character = new_character;
	game_area.add_child(new_controller);

func spawn_players():
	num_living_characters = game.num_players;
	
	for i in range(game.num_players):
		place_player(game.players[i]);

func on_character_death():
	num_living_characters -= 1;
	
	if (num_living_characters <= 1):
		begin_round_end();

func begin_round_start():
	anim.play("fade_in_black");

func on_anim_fade_in_end():
	start_round();

func start_round():
	can_place_bombs = true;
	can_move = true;

func begin_round_end():
	round_ending = true;
	can_place_bombs = false;
	set_process(true);

func _process(delta):
	if (round_ending):
		var bombs_placed = false;
		
		for entity in game_board.entities:
			if (entity.type == "bomb"):
				bombs_placed = true;
				break;
		
		if (!bombs_placed):
			end_round();

func end_round():
	round_ending = false;
	round_ended = true;
	
	can_move = false;
	
	for character in characters:
		if (character.alive):
			var player = game.players[character.player_num - 1];
			player.score += 1;
			break;
	
	player_scoreboard.update_displays();
	anim.play("fade_out_black");

func on_anim_fade_out_end():
	get_tree().change_scene("res://game/gamemodes/proto_mode.tscn");