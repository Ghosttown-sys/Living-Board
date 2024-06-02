extends Node2D

@onready var stairs = $Stairs_Collider
@onready var treasure = $Treasure_Collider


func _on_stairs_collider_body_entered(body):
	Game_Manager.leave_room.emit()
	Events.on_move_finished.emit()
	queue_free()


func _on_treasure_collider_body_entered(body):
	print(body)
	pass # Replace with function body.
