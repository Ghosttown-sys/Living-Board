extends Resource
class_name  Player_Stats_Res

const max_hp = 100
const max_sanity = 100
const max_actions = 7

var player_name : String
var player_health : int
var player_sanity : int

var player_actions : int

func reset():
	player_health = max_hp
	player_sanity = max_sanity
	player_actions = max_actions
	Events.on_player_stats_changed.emit()
