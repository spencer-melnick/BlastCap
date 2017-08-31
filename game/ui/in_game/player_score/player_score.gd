extends Control

export (int, 1, 4) var player_num = 1;

onready var sprite = get_node("Sprite");
onready var label = get_node("Label");

func _ready():
	duplicate_material();
	update_display();
	pass

func duplicate_material():
	sprite.set_material(sprite.get_material().duplicate());

func set_palette_num(player_num):
	var material = sprite.get_material();
	material.set_shader_param("palette_num", (player_num - 1) * 0.25 + 0.12);


func update_display():
	if (game.num_players >= player_num):
		show()
		set_palette_num(player_num);
		
		var player = game.players[player_num - 1];
		var score = player.score;
		
		label.set_text(str(score));
		
		if (score < game.get_highest_current_score()):
			sprite.set_frame(1);
		else:
			sprite.set_frame(0);
	else:
		hide();
