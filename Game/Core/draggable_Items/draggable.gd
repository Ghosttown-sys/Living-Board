extends Control
class_name  Draggable

@export var hoverSize : float = 1.3
@export var transition_type : Tween.TransitionType
@export var visual_node : Control

var initial_size : Vector2;
var initial_pos : Vector2
var initial_rot : float

var dragging : bool = false

@onready var parent :Card_UI = get_parent()

var tween;


func _ready():
	initial_size = visual_node.scale
	
	
func _on_collider_input_event(event):
	if Input.is_action_just_pressed("select_card"):
		#Events.remove_me.emit(parent)
		initial_pos = position
		initial_rot = rotation
		
		var tween = get_tree().create_tween()
		tween.tween_property(visual_node, "scale", Vector2(0.2,0.2), 0.8).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		
		dragging = true
	if Input.is_action_just_released("select_card"):
		
		var tween = get_tree().create_tween()
		tween.tween_property(visual_node, "scale", Vector2(1,1), 0.8).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
		dragging = false
		position = initial_pos
		rotation = initial_rot
		
func _process(_delta):
	if dragging:
		global_position = get_global_mouse_position() - size/2;
		rotation = -parent.rotation
		visual_node.z_index = Game_Manager.z_index_dragging_card
	else:
		visual_node.z_index = Game_Manager.z_index_idle_card
