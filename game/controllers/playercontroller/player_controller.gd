extends Node2D

var character;

export (int, 1, 4) var player_num = 1;
onready var player_str = "player" + str(player_num);

enum {HORIZONTAL, VERTICAL, NONE};
var priority_axis = NONE;

func _ready():
	set_process(true);
	set_process_input(true);
	pass

func _process(delta):
	var move_axis = Vector2();
	
	if (Input.is_action_pressed(player_str + "_up")):
		move_axis.y -= 1;
	if (Input.is_action_pressed(player_str + "_down")):
		move_axis.y += 1;
	if (Input.is_action_pressed(player_str + "_left")):
		move_axis.x -= 1;
	if (Input.is_action_pressed(player_str + "_right")):
		move_axis.x += 1;
	
	if (priority_axis == HORIZONTAL):
		if (move_axis.x != 0):
			character.move_x(delta * move_axis.x);
		elif (move_axis.y != 0):
			character.move_y(delta * move_axis.y);
	elif (priority_axis == VERTICAL):
		if (move_axis.y != 0):
			character.move_y(delta * move_axis.y);
		elif (move_axis.x != 0):
			character.move_x(delta * move_axis.x);

func _input(event):
	if (event.is_action_pressed(player_str + "_action")):
		character.place_bomb();
	elif (event.is_action_pressed(player_str + "_left") || event.is_action_pressed(player_str + "_right")):
		priority_axis = HORIZONTAL;
	elif (event.is_action_pressed(player_str + "_up") || event.is_action_pressed(player_str + "_down")):
		priority_axis = VERTICAL;
