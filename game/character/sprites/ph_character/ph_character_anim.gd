extends Sprite

const UP = Vector2(0, -1);
const DOWN = Vector2(0, 1);
const LEFT = Vector2(-1, 0);
const RIGHT = Vector2(1, 0);

onready var sample = get_node("SamplePlayer");
onready var anim = get_node("AnimationPlayer");
onready var character = get_parent();

var current_anim = "walk_down";
var playing = true;
var enabled = true;

export (int, 1, 4) var player_num = 1;

func _ready():
	anim.play("walk_down");
	anim.seek(0, true);
	anim.stop();
	
	set_material(get_material().duplicate());
	set_process(true);
	pass

func _process(delta):
	if (enabled):
		if (!playing):
			anim.stop();
		
		playing = false;

func set_palette_num(player_num):
	var material = get_material();
	material.set_shader_param("palette_num", (player_num - 1) * 0.25 + 0.12);

func walk(direction):
	if (enabled):
		var past_anim = current_anim;
		playing = true;
		
		if (direction == DOWN):
			current_anim = "walk_down";
		if (direction == UP):
			current_anim = "walk_up";
		if (direction == LEFT):
			current_anim = "walk_left";
		if (direction == RIGHT):
			current_anim = "walk_right";
		
		if (current_anim != past_anim):
			if (current_anim.find("walk") != -1 && past_anim.find("walk") != -1):
				var frame = anim.get_current_animation_pos();
				anim.play(current_anim);
				anim.seek(frame, true);
			else:
				anim.play(current_anim);

func explode():
	anim.play("death");
	enabled = false;


func on_footstep():
	sample.play("ph_step");


func on_anim_pop():
	sample.play("ph_hit");


func on_anim_death_end():
	anim.stop();
	character.on_anim_death_end();