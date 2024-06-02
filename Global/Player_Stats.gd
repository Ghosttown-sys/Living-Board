extends Node2D

const player_stat_res : Player_Stats_Res= preload("res://Game/Scenes/Player/Player_Stats.tres")
var player_stat : Player_Stats_Res

func _ready():
	player_stat = player_stat_res.duplicate()
	player_stat.reset()

func consume_action() -> bool:
	if player_stat.player_actions <= 0:
		return false
	player_stat.player_actions -= 1
	Events.on_player_stats_changed.emit()
	return true

func restore_all_actions():
	player_stat.player_actions = player_stat.max_actions
	Events.on_player_stats_changed.emit()

func take_damage(damage):
	player_stat.player_health -= damage
	Events.on_player_stats_changed.emit()

func take_sanity_damage(damage):
	player_stat.player_sanity -= damage
	Events.on_player_stats_changed.emit()
