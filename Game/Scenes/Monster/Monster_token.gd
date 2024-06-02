extends CharacterBody2D

@export var monster_data :Monster_Data
@onready var monster_sprite = $Monster_Sprite

func update():
	print(monster_data)
	monster_sprite.sprite_frames.set_frame("default",0,monster_data.sprite_frame_1)
	monster_sprite.play("default")
