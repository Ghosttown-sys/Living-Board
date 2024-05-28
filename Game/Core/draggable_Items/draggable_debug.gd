extends Control

@onready var draggable_item : Draggable = $"../../.."
@onready var label :Label= $Label
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	label.text = "dragging" if draggable_item.dragging else "idle";
