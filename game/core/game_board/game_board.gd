extends TileMap

var entities = [];
var characters = [];
var grid_size = Vector2();

export var solid_tiles = [];
export var breakable_tiles = [];
export (int) var broken_tile;

export (int, 0, 100) var bomb_powerup_rate = 15;
export (int, 0, 100) var radius_powerup_rate = 10;
export (int, 0, 100) var speed_powerup_rate = 7;

onready var powerup_scn = load("res://game/powerups/powerup.tscn");

func _ready():
	clear_random_cells(10);
	
	pass

func clear_random_cells(num):
	var removable_cells = [];
	
	for cell in get_used_cells():
		if (is_cell_breakable(cell)):
			removable_cells.push_back(cell);
	
	for i in range(0, num + 1):
		var index = randi() % removable_cells.size();
		set_cellv(removable_cells[index], broken_tile);
		removable_cells.remove(index);

func get_half_tile_offset():
	return get_cell_size() * get_scale() / 2;

func is_tile_solid(id):
	return solid_tiles.has(id);

func is_tile_breakable(id):
	return breakable_tiles.has(id);

func get_tile_progression(id):
	return broken_tile;

func get_characters_at_cell(pos):
	var result = [];
	
	for character in characters:
		if (character.cell_coord == pos):
			result.push_back(character);
	
	return result;

func get_entities_at_cell(pos):
	var result = [];
	
	for entity in entities:
		if (entity.cell_coord == pos):
			result.push_back(entity);
	
	return result;

func world_to_cell_coord(pos):
	pos -= (get_pos() + get_cell_size() * get_scale() / 2);
	pos /= get_cell_size() * get_scale();
	
	pos.x = round(pos.x);
	pos.y = round(pos.y);
	
	return pos;

func cell_to_local_coord(pos):
	pos *= get_cell_size();
	pos += get_cell_size() / 2;
	return pos;

func cell_to_world_coord(pos):
	pos *= get_cell_size() * get_scale();
	pos += (get_pos() + get_cell_size() * get_scale() / 2);
	return pos;

func snap_to_grid(pos):
	pos = world_to_cell_coord(pos);
	return cell_to_world_coord(pos);

func is_cell_solid(pos):
	for entity in get_entities_at_cell(pos):
		if (entity.solid):
			return true;

	return is_tile_solid(get_cellv(pos));

func is_cell_breakable(pos):
	return is_tile_breakable(get_cellv(pos));

func get_cell_progression(pos):
	return get_tile_progression(get_cellv(pos));

func progress_cell(pos):
	set_cellv(pos, get_cell_progression(pos));
	spawn_random_powerup(pos);

func spawn_random_powerup(pos):
	var bomb_rate_max = bomb_powerup_rate;
	var radius_rate_max = bomb_rate_max + radius_powerup_rate;
	var speed_rate_max = radius_rate_max + speed_powerup_rate;
	
	var chance = randi() % 100;
	
	if (chance <= bomb_rate_max):
		spawn_powerup("bomb", pos);
	elif (chance > bomb_rate_max && chance <= radius_rate_max):
		spawn_powerup("radius", pos);
	elif (chance > radius_rate_max && chance <= speed_rate_max):
		spawn_powerup("speed", pos);

func spawn_powerup(type, pos):
	var new_powerup = powerup_scn.instance();
	
	new_powerup.powerup_type = type;
	new_powerup.cell_coord = pos;
	new_powerup.set_pos(cell_to_local_coord(pos));
	
	add_child(new_powerup);
	entities.push_back(new_powerup);