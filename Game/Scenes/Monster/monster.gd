class_name Monster
extends CharacterBody2D

var max_hp := 10.0
var damage := 2
@onready var sprite :AnimatedSprite2D = $sprite

@export_group("sprite_animtion")
@export var frame_1 : AtlasTexture
@export var frame_2 : AtlasTexture


func _ready():
	sprite.sprite_frames.set_frame("default",0,frame_1)
	sprite.sprite_frames.set_frame("default",1,frame_2)
	sprite.play("default")

func take_damage(damage:float)->void:
	print(damage)
	print(max_hp)
	max_hp -= damage
	if max_hp <= 0:
		queue_free()
