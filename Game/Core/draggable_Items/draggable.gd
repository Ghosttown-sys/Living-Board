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
@onready var detector = $"../TextureRect/Detector"
@onready var board = $"/root/Run/Board"

var tween


func _ready():
	initial_size = visual_node.scale
	
	
func _on_collider_input_event(event):
	if event.is_action("select_card") and event.is_pressed() and not event.is_echo():
		initial_pos = position
		initial_rot = rotation
		AudioManager.pop_sfx.play()
		var tween = get_tree().create_tween()
		tween.tween_property(visual_node, "scale", Vector2(0.2,0.2), 0.8).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		
		dragging = true
	if event.is_action("select_card") and event.is_released() and not event.is_echo():
		AudioManager.pop_sfx.play()
		var target_room : Room = board.hovered_room
		if target_room != null:
			parent.apply_effect([target_room.coordinates])
			parent.queue_free()
		else:
			position = initial_pos
			rotation = initial_rot
			
		var tween = get_tree().create_tween()
		tween.tween_property(visual_node, "scale", Vector2(1,1), 0.8).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)	
		dragging = false
		
func _process(_delta):
	if dragging:
		detector.set_collision_layer_value(1,true)
		global_position = get_global_mouse_position() - size/2;
		rotation = -parent.rotation
		visual_node.z_index = Game_Manager.z_index_dragging_card
	else:
		detector.set_collision_layer_value(1,false)
		visual_node.z_index = Game_Manager.z_index_idle_card
