extends Sprite

var player = null;
var cell_coord = Vector2();

const type = "fire";
var solid = false;
var trigger = true;

var fire_type = "cross_burn";
var lethal = true;

onready var anim = get_node("AnimationPlayer");
onready var grid = get_parent();

func _ready():
	anim.play(fire_type);
	anim.seek(0, true);
	
	if (fire_type == "cross_burn"):
		solid = true;

func on_anim_end():
	remove_from_game();

func remove_from_game():
	grid.entities.erase(self);
	queue_free();

func on_anim_lethal_break():
	lethal = false;
	trigger = false;

func on_trigger(char):
	char.die();
