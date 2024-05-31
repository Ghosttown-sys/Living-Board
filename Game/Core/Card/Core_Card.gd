class_name Card_UI
extends Control
@onready var hand = get_parent() 
@export var rotation_curve : Curve
var card_effects_database = preload("res://Game/Core/cards/cards_database.tres")

@onready var artwork = $TextureRect/Artwork
@onready var description = $TextureRect/Description

var original_index := 0
var parent: Control
var tween: Tween
var rotation_tween : Tween
var disabled := false
var card_anime = null
var card_rotation :float

var card_effect : Card_Effect

var dragging :
	get: 
		if $Draggable_Item == null:
			return false
		else:
			return $Draggable_Item.dragging

# Called when the node enters the scene tree for the first time.
func _ready():
	card_anime = get_node("card_anime")

func initialize_card_effect():
	card_effect = card_effects_database.card_effects[randi_range(0, card_effects_database.card_effects.size() - 1)]
	artwork.texture = card_effect.artwork
	description.text = card_effect.description

func apply_effect(args):
	card_effect.apply_effect(args)

func animate_to_position(new_position: Vector2, duration: float, new_rotation: float) -> void:
	tween = create_tween().set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "global_position", new_position, duration)
	self.rotation = -new_rotation

func _on_control_mouse_entered():
	card_anime.play("focus")
	
func _on_control_mouse_exited():
	card_anime.play_backwards("focus")
