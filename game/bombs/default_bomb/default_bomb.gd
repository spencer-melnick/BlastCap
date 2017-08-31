extends Sprite

# Game entities

onready var anim = get_node("AnimationPlayer");
onready var sound = get_node("SamplePlayer");
onready var timer = get_node("Timer");
onready var grid = get_parent();
onready var game_area = grid.get_parent();
onready var game_mode = game_area.get_parent();
onready var camera = game_area.get_node("Camera2D");


# Resources

onready var fire_scn = load("res://game/bombs/fire/fire.tscn");
onready var burn_scn = load("res://game/core/tile_burn/tile_burn.tscn");


# Local variables

var player = null;
var default_radius = 2;
var cell_coord = Vector2();
var disabled = false;


# Type info

const type = "bomb";
const solid = true;
const trigger = false;


# Constants 

const up = Vector2(0, -1);
const down = Vector2(0, 1);
const left = Vector2(-1, 0);
const right = Vector2(1, 0);
const directions = [up, down, left, right];

func _ready():
	anim.play("default_explode");
	pass

func _process(delta):
	if (disabled && !sound.is_active()):
		queue_free();

func on_anim_explode():
	if (!disabled):
		sound.play("ph_explode");
		camera.shake();
		
		if (player != null):
			explode(player.bomb_radius);
		else:
			explode(default_radius);

func explode_delayed(radius):
	timer.set_wait_time(0.07);
	timer.connect("timeout", self, "explode", [radius]);
	timer.start();
	
	disabled = true;

func explode(radius):
	if (player != null):
		player.active_bombs -= 1;
	
	grid.entities.erase(self);
	spawn_fire(radius);
	
	disabled = true;
	hide();
	set_process(true);

func place_fire(pos, direction, cap):
	var new_fire = fire_scn.instance();
	
	new_fire.cell_coord = pos;
	new_fire.set_pos(grid.cell_to_local_coord(pos));
	
	if (!cap):
		if (direction == left || direction == right):
			new_fire.fire_type = "horiz_burn";
		elif (direction == up || direction == down):
			new_fire.fire_type = "vert_burn";
	elif (cap):
		if (direction == left):
			new_fire.fire_type = "cap_left_burn";
		elif (direction == right):
			new_fire.fire_type = "cap_right_burn";
		elif (direction == up):
			new_fire.fire_type = "cap_up_burn";
		elif (direction == down):
			new_fire.fire_type = "cap_down_burn";
		else:
			new_fire.fire_type = "cross_burn";
	
	for entity in grid.get_entities_at_cell(pos):
		if (entity.type == "fire"):
			entity.remove_from_game();
	
	for i in grid.get_characters_at_cell(pos):
		i.die();
	
	grid.add_child(new_fire);
	grid.entities.push_back(new_fire);

func place_tile_burn(pos):
	var new_burn = burn_scn.instance();
	new_burn.cell_coord = pos;
	new_burn.set_pos(grid.cell_to_local_coord(pos));
	
	grid.add_child(new_burn);
	grid.entities.push_back(new_burn);

func spawn_fire(radius):
	place_fire(cell_coord, Vector2(), true);
	
	for direction in directions:
		for dist in range(1, radius + 1):
			var fire_cell = cell_coord + direction * dist;
			var cell_flammable = true;
			
			for entity in grid.get_entities_at_cell(fire_cell):
				if (entity.type == "bomb"):
					entity.explode_delayed(radius);
					cell_flammable = false;
				if (entity.type == "powerup"):
					entity.burn();
					cell_flammable = false;
			
			if (cell_flammable):
				if (!grid.is_cell_solid(fire_cell)):
					place_fire(fire_cell, direction, (dist == radius));
				elif (grid.is_cell_breakable(fire_cell)):
					grid.progress_cell(fire_cell);
					place_tile_burn(fire_cell);
					break;
				else:
					break;
			else:
				break;