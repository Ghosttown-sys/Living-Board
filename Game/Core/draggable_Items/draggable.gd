extends Control
class_name  draggable

@export var hoverSize : float = 1.3
@export var transition_type : Tween.TransitionType
@export var visual_node : Control

var initial_size : Vector2;
var initial_pos : Vector2
var initial_rot : float

var dragging : bool = false

@onready var parent = get_parent()

var tween;


func _ready():
	initial_size = visual_node.scale;
	
func _on_collider_input_event(event):
	if Input.is_action_just_pressed("select_card"):
		
		initial_pos = position
		initial_rot = rotation
		
		dragging = true
	if Input.is_action_just_released("select_card"):
		dragging = false
		position = initial_pos
		rotation = initial_rot
		
func _process(_delta):
	if dragging:
		global_position = get_global_mouse_position() - size/2;
		rotation = -parent.rotation
		visual_node.z_index = 10
	else:
		visual_node.z_index = 0
