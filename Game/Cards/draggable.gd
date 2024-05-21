extends Node2D
class_name  draggable

@export var hoverSize : float = 1.3
@export var transition_type : Tween.TransitionType
@export var visual_node : Node2D

var initial_size : Vector2;
var dragging : bool = false
var hovering : bool = false

var tween;

func _ready():
	initial_size = visual_node.scale;

func _on_hover_start():
	tween_size(initial_size * hoverSize)
	hovering = true
	
func _on_hover_end():
	tween_size(initial_size)
	hovering = false
	
func _on_collider_input_event(event):
	if not event is InputEventMouseButton:
		return;
		
	if event.pressed:
		dragging = true
	else:
		dragging = false
		position = Vector2.ZERO
		
func _process(_delta):
	if dragging:
		global_position = get_global_mouse_position();
		visual_node.z_index = 10
	else:
		visual_node.z_index = 0
	
func handle_hover():
	if hovering:
		pass
	else:
		pass
	
func tween_size(size : Vector2):
	if tween:
		tween.kill() # Abort the previous animation.
	tween = create_tween();
	tween.tween_property(visual_node, "scale", size, 0.2).set_ease(Tween.EASE_OUT).set_trans(transition_type)

