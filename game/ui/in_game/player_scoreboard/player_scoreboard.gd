extends Control

var score_displays = [];

func _ready():
	get_score_displays();
	pass

func get_score_displays():
	score_displays.clear();
	
	for i in range(1, game.num_players + 1):
		score_displays.push_back(get_node("PlayerScore" + str(i)));
		
	return score_displays;

func update_displays():
	for display in score_displays:
		display.update_display();