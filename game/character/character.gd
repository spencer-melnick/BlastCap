extends Node2D

# Constants


# Editor values

export var walk_speed = 120.0;
export(int, 1, 99) var max_bombs = 1;
export(int, 1, 99) var bomb_radius = 1;


# Game entities

onready var game_mode = get_parent().get_parent();
onready var grid = get_parent().get_node("GameBoard");
onready var sprite = get_node("CharacterAnim");


# Resources

onready var bomb_scn = load("res://game/bombs/default_bomb/default_bomb.tscn");


# Local variables

var active_bombs = 0;
var last_cell = Vector2();
var cell_coord = Vector2();
var alive = true;
var player_num = 1;


func _ready():
	cell_coord = grid.world_to_cell_coord(get_pos());
	game_mode.characters.push_back(self);
	sprite.set_palette_num(player_num);
	pass;


func get_touching_cells(pos):
	# Returns the coordinates of any cells touching "pos"
	var adj_cells = [];
	
	pos -= (grid.get_pos() + grid.get_cell_size() * grid.get_scale() / 2);
	pos /= grid.get_cell_size() * grid.get_scale();
	
	var top_left = pos.floor();
	var bottom_right = Vector2(ceil(pos.x), ceil(pos.y));
	var top_right = Vector2(bottom_right.x, top_left.y);
	var bottom_left = Vector2(top_left.x, bottom_right.y);
	
	adj_cells.push_back(top_left);
	if (!adj_cells.has(bottom_right)):
		adj_cells.push_back(bottom_right);
	if (!adj_cells.has(top_right)):
		adj_cells.push_back(top_right);
	if (!adj_cells.has(bottom_left)):
		adj_cells.push_back(bottom_left);
	
	return adj_cells;



func is_touching_cell(cell):
	return get_touching_cells().has(cell);


func is_touching_solid_cell(pos):
	for i in get_touching_cells(pos):
		if (grid.is_cell_solid(i)):
			return true;
	return false;


func is_touching_solid_cell_except(pos, exception):
	for i in get_touching_cells(pos):
		if (grid.is_cell_solid(i) && i != exception):
			return true;
	return false;


func check_cell():
	var pos = get_pos();
	cell_coord = grid.world_to_cell_coord(pos);
	
	if (cell_coord != last_cell):
		for entity in grid.get_entities_at_cell(cell_coord):
			if (entity.trigger):
				entity.on_trigger(self);
		
		last_cell = cell_coord;


func die():
	if (alive):
		sprite.explode();
		alive = false;


func move_x(delta):
	if (alive && game_mode.can_move):
		var pos = get_pos();
		var next_pos = pos + Vector2(delta * walk_speed, 0);
		
		# Check to see if all cells we're stepping into are free
		var edge_pos = next_pos + grid.get_half_tile_offset() * Vector2(sign(delta), 0);
		edge_pos.x = grid.snap_to_grid(edge_pos).x;
		
		if (!is_touching_solid_cell_except(edge_pos, cell_coord)):
			set_pos(next_pos);
			sprite.walk(Vector2(sign(delta), 0));
		else:
			# If all cells aren't free, check to see if any are free
			
			var stepping_cells = get_touching_cells(edge_pos);
			var open_step = false;
			var open_step_cell = Vector2();
			
			for i in stepping_cells:
				if (!grid.is_cell_solid(i)):
					open_step = true;
					open_step_cell = i;
					break;
			
			# Move perpendicularly until reaching open cell
			if (open_step):
				var dist = grid.cell_to_world_coord(open_step_cell).y - pos.y;
				
				if (abs(dist) < grid.get_half_tile_offset().y * 1.5):
					var clamped_dist = clamp(dist / walk_speed, -abs(delta), abs(delta));
					next_pos = pos + Vector2(0, clamped_dist * walk_speed);
					
					# If 1/4 tile away from open cell, move diagonally
					if (abs(dist) < grid.get_half_tile_offset().y / 2):
						next_pos += Vector2(abs(clamped_dist) * sign(delta) * walk_speed, 0);
						sprite.walk(Vector2(sign(delta), 0));
					else:
						sprite.walk(Vector2(0, sign(dist)));
					
					set_pos(next_pos);
		
		check_cell();

func move_y(delta):
	if (alive && game_mode.can_move):
		var pos = get_pos();
		var next_pos = pos + Vector2(0, delta * walk_speed);
		
		# Check to see if all cells we're stepping into are free
		var edge_pos = next_pos + grid.get_half_tile_offset() * Vector2(0, sign(delta));
		edge_pos.y = grid.snap_to_grid(edge_pos).y
		
		if (!is_touching_solid_cell_except(edge_pos, cell_coord)):
			set_pos(next_pos);
			sprite.walk(Vector2(0, sign(delta)));
		else:
			# If all cells aren't free, check to see if any nearby are free
			
			var stepping_cells = get_touching_cells(edge_pos);
			var open_step = false;
			var open_step_cell = Vector2();
			
			for i in stepping_cells:
				if (!grid.is_cell_solid(i)):
					open_step = true;
					open_step_cell = i;
					break;
			
			# Move perpendicularly until reaching open cell
			if (open_step):
				var dist = grid.cell_to_world_coord(open_step_cell).x - pos.x;
				
				if (abs(dist) < grid.get_half_tile_offset().x * 1.5):
					var clamped_dist = clamp(dist / walk_speed, -abs(delta), abs(delta));
					next_pos = pos + Vector2(clamped_dist * walk_speed, 0);
					
					# If 1/4 tile away from open cell, move diagonally
					if (abs(dist) < grid.get_half_tile_offset().x / 2):
						next_pos += Vector2(0, abs(clamped_dist) * sign(delta) * walk_speed);
						sprite.walk(Vector2(0, sign(delta)));
					else:
						sprite.walk(Vector2(sign(dist), 0));
					
					set_pos(next_pos);
		
		check_cell();


func place_bomb():
	if (alive && game_mode.can_place_bombs && active_bombs < max_bombs && !grid.is_cell_solid(cell_coord)):
		active_bombs += 1;
		
		var pos = get_pos();
		
		var new_bomb = bomb_scn.instance();
		new_bomb.player = self;
		new_bomb.cell_coord = cell_coord;
		
		new_bomb.set_pos(grid.cell_to_local_coord(cell_coord));
		grid.entities.push_back(new_bomb);
		grid.add_child(new_bomb);


func on_anim_death_end():
	game_mode.on_character_death();
