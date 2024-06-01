extends Node2D
@onready var board = $Board
@onready var turn_controler = $Turn_Controler

const COMBAT = preload("res://Game/Scenes/Combat/combat.tscn")
@onready var camera :Camera2D= $Camera

@onready var hp = $Top_Bar/Menu/Profile/Profile/Stats/HP
@onready var sanity = $Top_Bar/Menu/Profile/Profile/Stats/Sanity
@onready var turn_counter = $Top_Bar/Menu/Turn/Turn_Counter
@onready var phase = $Top_Bar/Menu/Game_State/Phase


func _on_button_pressed():
	AudioManager.play_music(2)
	toggle_visiblity()
	var new_combat := COMBAT.instantiate()
	new_combat.temp = 5
	add_child(new_combat)


func toggle_visiblity():
	turn_controler.hide()
	board.visible =false
	board.buttons.hide()
