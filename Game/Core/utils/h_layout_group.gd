@tool
extends Node2D

@export var spacing: float = 10.0  # Spacing between sprites

func _process(delta):
	arrange_sprites()

func arrange_sprites():
	var current_x = 0.0
	
	for child in get_children():
		if child is Node2D:
			var node = child as Node2D
			node.position.x = current_x
			node.global_position.y = global_position.y
			current_x += spacing
