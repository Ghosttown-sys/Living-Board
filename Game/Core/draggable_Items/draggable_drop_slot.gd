extends Control
class_name Draggable_Drop_Slot 

@onready var visuals : Control = $Visuals
@onready var debug_label = $Label

var is_row :bool
var direction : Game_Manager.DIRECTION
var index : int

func initialize(is_row :bool, direction : Game_Manager.DIRECTION , index :int,size: Vector2):
	await self.ready
	visuals.custom_minimum_size = size
	self.is_row = is_row
	self.direction = direction
	self.index = index
	debug_label.text = "";
	debug_label.text += "is_row: "+ str(is_row) + "\n"
	debug_label.text += "direction: "+ str(Game_Manager.DIRECTION.keys()[direction]) + "\n"
	debug_label.text += "index: "+ str(index) + "\n"

func trigger(event):
	if event is InputEventMouseButton and event.pressed and \
			event.button_index == MOUSE_BUTTON_LEFT:
		if is_row:
			Board_Manipulator.push_row(index, direction)
		else:
			Board_Manipulator.push_column(index, direction)
		Events.board_move_begin.emit();


func _on_drop_point_detector_body_entered(body):
	print("hi")
	pass # Replace with function body.
