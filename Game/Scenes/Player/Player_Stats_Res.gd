extends Resource
class_name  Player_Stats_Res

@export var max_hp = 100
@export var max_sanity = 100
@export var max_actions = 3

var player_name : String
var player_health : int
var player_sanity : int

var player_actions : int

func reset():
	player_health = max_hp
	player_sanity = max_sanity
	player_actions = max_actions
	Events.on_player_stats_changed.emit()
