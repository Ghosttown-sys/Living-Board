extends Node2D

var room

func _ready():
	room = get_parent()
	
func _process(delta):
	rotation = -room.rotation
