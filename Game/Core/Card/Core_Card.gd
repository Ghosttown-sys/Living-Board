class_name CardUI
extends Control
@onready var hand = get_parent() 
@export var rotation_curve : Curve;
var original_index := 0
var parent: Control
var tween: Tween
var rotation_tween : Tween
var disabled := false
var card_anime = null
var card_rotation :float;

var dragging :
	get: 
		if $Draggable_Item == null:
			return false
		else:
			return $Draggable_Item.dragging

# Called when the node enters the scene tree for the first time.
func _ready():
	card_anime = get_node("card_anime")

func animate_to_position(new_position: Vector2, duration: float, new_rotation: float) -> void:
	tween = create_tween().set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "global_position", new_position, duration)
	self.rotation = -new_rotation


func _on_control_mouse_entered():
	card_anime.play("focus")
	

func _on_control_mouse_exited():
	card_anime.play_backwards("focus")
