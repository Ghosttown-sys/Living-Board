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
	AudioManager.take_damage_sfx.play()
	Events.hp_lost.emit()
	player_stat.player_health -= damage
	Events.on_player_stats_changed.emit()
	if player_stat.player_health <= 0 and player_stat.player_alive:
		Events.player_died.emit()
		player_stat.player_alive = false
	
func heal():
	Events.hp_gained.emit()
	player_stat.player_health += 20
	if player_stat.player_health>player_stat.max_hp:
		player_stat.player_health = player_stat.max_hp

func take_sanity_damage(damage):
	player_stat.player_sanity -= damage
	Events.on_player_stats_changed.emit()

func reset_player():
	player_stat.reset()
