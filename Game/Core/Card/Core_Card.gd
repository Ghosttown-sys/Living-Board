class_name Card_UI
extends Control
@onready var hand = get_parent() 
@export var rotation_curve : Curve;
var parent: Control
var tween: Tween
var disabled := false
var card_anime = null

var draggable_card = preload("res://Game/Core/cards/draggable_card.tscn")
var draggable_card_instance;

var dragging :
	get: 
		if draggable_card_instance == null:
			return false
		else:
			return draggable_card_instance.dragging

# Called when the node enters the scene tree for the first time.
func _ready():
	card_anime = get_node("card_anime")
	Events.on_card_returned_to_hand.connect(_on_draggable_card_released)

func animate_to_position(new_position: Vector2, duration: float, new_rotation: float) -> void:
	tween = create_tween().set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "global_position", new_position, duration)
	self.rotation = -new_rotation


func _on_control_mouse_entered():
	card_anime.play("focus")
	

func _on_control_mouse_exited():
	card_anime.play_backwards("focus")

# When clicked, create a new 2dNode object to act as the draggable object
func _on_texture_rect_gui_input(event):
	if Input.is_action_just_pressed("select_card"):
		draggable_card_instance = draggable_card.instantiate()
		hand.draggable_items_parent.add_child(draggable_card_instance)
		draggable_card_instance.in_hand_card = self
		draggable_card_instance.position = position
		draggable_card_instance.start_dragging()
		visible = false

func _on_draggable_card_released(card):
	if card == self: 
		visible = true
