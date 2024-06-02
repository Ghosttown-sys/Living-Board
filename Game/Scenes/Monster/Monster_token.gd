extends CharacterBody2D

var monster_data :Monster_Data
@onready var monster_sprite = $Monster_Sprite

func update():
	
	monster_sprite.sprite_frames = monster_sprite.sprite_frames.duplicate()
	monster_sprite.sprite_frames.set_frame("default",0,monster_data.sprite_frame_1)
	monster_sprite.play("default")

func _process(delta):
	rotation = -get_parent().rotation
