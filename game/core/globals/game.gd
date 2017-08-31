extends Node

enum ControlType {PLAYER_CONTROLLER, AI_CONTROLLER};

class Player:
	var player_num = 1;
	var score = 0;
	var control_type = ControlType.PLAYER_CONTROLLER;
	
	func _init(num):
		player_num = num;

var num_players = 2;
var players = [Player.new(1), Player.new(2)];

func get_highest_current_score():
	var high_score = 0;
	
	for player in players:
		high_score = max(high_score, player.score);
	
	return high_score;
