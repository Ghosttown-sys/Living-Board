class_name Monster
extends CharacterBody2D

var max_hp := 10.0
var damage := 2
var speed := 800.0
var rush_speed := 16000.0
var cd := 5.0

@onready var animation_player = $AnimationPlayer
@onready var sprite :AnimatedSprite2D = $sprite
@onready var timer = $Timer

var player : Player
var is_dying : bool = false
var is_dashing : bool = false
var direction : Vector2

@export_group("sprite_animtion")
@export var frame_1 : AtlasTexture
@export var frame_2 : AtlasTexture
@onready var shooter = $Shooter

enum Monster_Type{
	MELEE,
	RANGED,
	RUSHER,
}

@export var distance_from_player : int = 32

@export_category("Monster_Type")
@export var monster_type : Monster_Type = Monster_Type.RANGED
const ARROW = preload("res://Game/Components/Bullets/Enemy_Arrow.tscn")

func _ready():
	sprite.sprite_frames.set_frame("default",0,frame_1)
	sprite.sprite_frames.set_frame("default",1,frame_2)
	sprite.play("default")
	player = get_tree().get_first_node_in_group("Player")
	timer.start(cd)

func _physics_process(delta):
	if is_instance_valid(player) and !is_dying:
		direction = (player.global_position - global_position).normalized()
		if !is_dashing:
			if position.distance_to(player.position) > distance_from_player:
				velocity = speed * delta * direction
			else:
				velocity = Vector2.ZERO
		else:
			if position.distance_to(player.position) > 0:
				velocity = rush_speed * delta * direction

		if direction.x  <0 :
			sprite.flip_h = true
		else:
			sprite.flip_h = false
		move_and_slide()

func take_damage(damage:float)->void:
	if !is_dying:
		max_hp -= damage
		if max_hp <= 0:
			is_dying = true
			animation_player.play("Death")
			$explosion_effect.emitting = true
			await get_tree().create_timer(1).timeout
			queue_free()


func _on_timer_timeout():
	if !is_dying:
		match monster_type:
				Monster_Type.RANGED:
					shoot()
				Monster_Type.MELEE:
					is_dashing = true
					print("dash end")
					await get_tree().create_timer(1).timeout
					dash()

func shoot():
	var arrow = [null]
	for i in range(1,arrow.size()+1):
			arrow[i-1] = ARROW.instantiate()
			arrow[i-1].rotation = direction.angle()
			arrow[i-1].direction = direction
			arrow[i-1].global_position = shooter.global_position
			arrow[i-1].bullet_damage = damage
			if !is_dying:
				get_tree().get_root().add_child(arrow[i-1])
				timer.start(cd)
				

func dash():
	print("dash start")
	is_dashing = false
	timer.start()




func _on_melee_zone_body_entered(body):
	if body is Player and monster_type == Monster_Type.MELEE:
		body.take_damage(damage)
		is_dashing = false
		print(is_dashing)
