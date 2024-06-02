class_name Monster
extends CharacterBody2D

@export var monster_data :Monster_Data

var max_hp := 10.0
var damage := 2
var speed := 800.0
var rush_speed := 16000.0
var cd := 1.5
var cdm := 3.0


@onready var animation_player = $AnimationPlayer
@onready var sprite :AnimatedSprite2D = $sprite
@onready var timer = $Timer
@onready var hp_bar = $HP_BAR

var player : Player
var is_dying : bool = false
var is_dashing : bool = false
var direction : Vector2

@export_group("sprite_animtion")
@export var frame_1 : AtlasTexture
@export var frame_2 : AtlasTexture
@onready var shooter = $Shooter


@export var distance_from_player : int = 32

@export_category("Monster_Type")
@export var monster_type : Monster_Data.MONSTER_TYPE = Monster_Data.MONSTER_TYPE.RANGED
const ARROW = preload("res://Game/Components/Bullets/Enemy_Arrow.tscn")

func _ready():
	set_up_monster()
	set_up_animation()
	monster_in_it()

func monster_in_it():
	player = get_tree().get_first_node_in_group("Player")
	timer.start(cd)
	hp_bar.max_value = max_hp
	

func _physics_process(delta):
	hp_bar.value = max_hp
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

func set_up_monster():
	max_hp = monster_data.max_hp + Game_Manager.turn *2
	damage = monster_data.damage + Game_Manager.turn *1
	speed = monster_data.speed
	rush_speed = monster_data.rush_speed
	cd = monster_data.cd
	cdm =monster_data.cdm
	frame_1 = monster_data.sprite_frame_1
	frame_2 = monster_data.sprite_frame_2
	monster_type = monster_data.monster_type
	

func set_up_animation():
	sprite.sprite_frames = sprite.sprite_frames.duplicate()
	sprite.sprite_frames.set_frame("default",0,frame_1)
	sprite.sprite_frames.set_frame("default",1,frame_2)
	sprite.play("default")

func take_damage(damage:float)->void:
	if !is_dying:
		max_hp -= damage
		if max_hp <= 0:
			is_dying = true
			animation_player.play("Death")
			await get_tree().create_timer(0.1).timeout
			hp_bar.hide()
			$explosion_effect.emitting = true
			Game_Manager.monsters_alive -=1
			await get_tree().create_timer(1).timeout
			queue_free()


func _on_timer_timeout():
	if !is_dying:
		match monster_type:
				Monster_Data.MONSTER_TYPE.RANGED:
					shoot()
				Monster_Data.MONSTER_TYPE.MELEE:
					is_dashing = true
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
				timer.start(randf_range(cd,cdm))
				

func dash():
	is_dashing = false
	timer.start()




func _on_melee_zone_body_entered(body):
	if body is Player and monster_type == Monster_Data.MONSTER_TYPE.MELEE:
		body.take_damage(damage)
		is_dashing = false
