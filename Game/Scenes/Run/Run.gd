extends Node2D
@onready var debug = $Debug
@onready var board = $Board

const COMBAT = preload("res://Game/Scenes/Combat/combat.tscn")
@onready var camera :Camera2D= $Camera


func _on_button_pressed():
	toggle_visiblity()
	var new_combat := COMBAT.instantiate()
	new_combat.temp = 5
	add_child(new_combat)


func toggle_visiblity():
	debug.hide()
	board.visible =false
	board.buttons.hide()
	
	
