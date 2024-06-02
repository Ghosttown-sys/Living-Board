extends Node2D
@onready var board = $Board
@onready var turn_controler = $Turn_Controler

const COMBAT = preload("res://Game/Scenes/Combat/combat.tscn")
@onready var camera :Camera2D= $Camera

@onready var hp = $Top_Bar/Menu/Profile/Profile/Stats/HP
@onready var sanity = $Top_Bar/Menu/Profile/Profile/Stats/Sanity
@onready var turn_counter = $Top_Bar/Menu/Turn/Turn_Counter
@onready var actions = $Top_Bar/Menu/Game_State/Action_Tokens

const action_token_scene = preload("res://Game/Scenes/UI/action_token.tscn")



func _ready():
	Game_Manager.combat_done.connect(toggle_visiblity_on)
	
	for i in PlayerStats.player_stat.max_actions:
		var instance = action_token_scene.instantiate()
		actions.add_child(instance)
	
	Events.on_player_stats_changed.connect(_on_stats_changed)
	_on_stats_changed()


func _process(delta):
	hp.value = PlayerStats.player_stat.player_health
	sanity.value = PlayerStats.player_stat.player_sanity
	
func _on_stats_changed():
	for token in actions.get_children():
		token.visible = false
	for i in PlayerStats.player_stat.player_actions:
		actions.get_child(i).visible = true	
	
	hp.max_value = PlayerStats.player_stat.max_hp
	sanity.max_value = PlayerStats.player_stat.max_sanity
	


func _on_button_pressed():
	AudioManager.play_music(2)
	toggle_visiblity_off()
	var new_combat := COMBAT.instantiate()
	add_child(new_combat)


func toggle_visiblity_off():
	turn_controler.hide()
	board.visible =false
	board.buttons.hide()
	
func toggle_visiblity_on():
	turn_controler.show()
	board.visible =true
	board.buttons.show()
	camera.make_current()


func _on_end_turn_pressed():
	PlayerStats.restore_all_actions()
