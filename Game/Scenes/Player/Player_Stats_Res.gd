extends Resource
class_name  Player_Stats_Res

@export var max_hp = 100
@export var max_sanity = 100
@export var max_actions = 3

@export var player_attack :int = 2


enum Attack_Type{
	MELEE,
	RANGED,
	MAGIC,
	SEEKER
}

@export_category("Attack_Type")
@export var attack_type : Attack_Type = Attack_Type.MELEE


var player_name : String
var player_health : int
var player_sanity : int

var player_alive : bool

var player_actions : int

func reset():
	player_alive = true
	player_health = max_hp
	player_sanity = max_sanity
	player_actions = max_actions
	Events.on_player_stats_changed.emit()
