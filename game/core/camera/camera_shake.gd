extends Camera2D

var start_pos = Vector2()
var shaking = false;
var elapsed_time = 0;
var phase = 0;

func _ready():
	start_pos = get_pos();
	
	set_process(true);
	pass

func _process(delta):
	if (shaking):
		elapsed_time += delta;
		if (elapsed_time > 1):
			shaking = false;
			elapsed_time = 0;
			set_pos(start_pos);
		else:
			set_pos(start_pos + 0.5 * Vector2(horiz_shake(elapsed_time), vert_shake(elapsed_time)));

func shake():
	elapsed_time = 0;
	phase = rand_range(-3, 3);
	shaking = true;

func horiz_shake(time):
	return round(sin(exp(2 - 4 * time) + phase) * exp(0.5 - 5 * time));

func vert_shake(time):
	return round(cos(exp(3 - 3 * time) + phase) * exp(0.5 - 5 * time));