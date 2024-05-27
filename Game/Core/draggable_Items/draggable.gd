extends Node2D
class_name  Draggable

var in_hand_card;

@onready var visual_node : Node2D = $Visual
@onready var drag_target : Node2D = $Draggable_Target

var initial_size : Vector2;
var initial_pos : Vector2
var initial_rot : float

var dragging : bool = false

var tween;

func _ready():
	initial_size = visual_node.scale
	
func start_dragging():
	initial_rot = in_hand_card.rotation
	tween = get_tree().create_tween()
	tween.tween_property(visual_node, "scale", Vector2(0.5,0.5), 0.8).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	dragging = true
		
func stop_dragging():
	tween = get_tree().create_tween()
	var resize_tween = tween.tween_property(visual_node, "scale", initial_size, 1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
	dragging = false
	drag_target.position = initial_pos
	drag_target.rotation = initial_rot
	
	await resize_tween.finished
	
	#await get_tree().create_timer(1).timeout
	queue_free()
	Events.on_card_returned_to_hand.emit(in_hand_card)
	
		
func _process(_delta):
	if dragging:
		drag_target.global_position = get_global_mouse_position();
		visual_node.z_index = Game_Manager.z_index_dragging_card
	else:
		visual_node.z_index = Game_Manager.z_index_idle_card
	
	# When mouse button is release, destroy the object
	if Input.is_action_just_released("select_card"):
		drag_target.position = initial_pos;
		stop_dragging()
