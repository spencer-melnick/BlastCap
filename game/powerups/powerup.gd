extends Sprite

const type = "powerup";
const solid = false;
var trigger = true;
var deleted = false;

var powerup_type = "bomb";
var cell_coord = Vector2();

onready var anim = get_node("AnimationPlayer");
onready var sound = get_node("SamplePlayer");
onready var grid = get_parent();

func _ready():
	anim.play(powerup_type + "_flicker");
	anim.seek(0, true);
	pass

func powerup_character(char):
	if (powerup_type == "bomb"):
		char.max_bombs += 1;
	if (powerup_type == "radius"):
		char.bomb_radius += 1;
	if (powerup_type == "speed"):
		char.walk_speed += 15
	
	sound.play("ph_powerup");
	remove_from_game();

func remove_from_game():
	grid.entities.erase(self);
	delete_on_sound_end();

func delete_on_sound_end():
	deleted = true;
	hide();
	set_process(true);

func _process(delta):
	if (deleted && !sound.is_active()):
		queue_free();

func on_trigger(char):
	powerup_character(char);

func on_anim_burn_end():
	remove_from_game();

func burn():
	trigger = false;
	anim.play("burn");
	sound.play("ph_burn");