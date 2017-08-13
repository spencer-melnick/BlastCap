extends Sprite

onready var grid = get_parent();
onready var anim = get_node("AnimationPlayer");

var cell_coord = Vector2();

const type = "tile_burn";
const solid = true;

func _ready():
	anim.play("tile_burn");
	pass

func on_anim_end():
	grid.entities.erase(self);
	queue_free();
