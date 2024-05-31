class_name Player
extends CharacterBody2D

signal toggle_inventory


# Exports
@export_category("Stats")
@export var speed :int = 50
@export var max_hp : int = 10
@export var hp :int
@export var atk : int 

@onready var animation_tree : AnimationTree = $Visual_Component/AnimationTree
@onready var mood : Label = $Visual_Component/Mood
@onready var interaction_component = $Interaction_Component
@onready var camera = $Camera
@onready var weapon_holder = $Weapon_Holder
@onready var melee_marker = $Weapon_Holder/melee_marker
@onready var sprite = $Weapon_Holder/Weapon_Zone/Weapon/Sprite
@onready var weapon_zone = $Weapon_Holder/Weapon_Zone
@onready var magic = $Weapon_Holder/Magic

var can_move = false
var direction : Vector2 = Vector2.UP
var input_direction :Vector2
var dying : bool = false
var attacking : bool = false
var damage : int = 1
#room info
var current_room :Room

enum Attack_Type{
	MELEE,
	RANGED,
	MAGIC,
	SEEKER
}

enum Current_State {
	IDLE,
	WALK
}

@export_category("State_Machine")
@export var current_state : Current_State = Current_State.IDLE

@export_category("Attack_Type")
@export var attack_type : Attack_Type = Attack_Type.MELEE

func _ready():
	camera.make_current()
	can_move = true
	animation_tree.active = true
	hp = max_hp
	set_weapon()

func _physics_process(delta: float) -> void :
	if not dying:
		update_aim()
		attack_check(delta)
		update_animation()
		update_camera()
		move_and_slide()

func update_animation():
	animation_tree["parameters/conditions/idle"] = current_state == Current_State.IDLE
	animation_tree["parameters/conditions/is_moving"] = current_state == Current_State.WALK
	
	match current_state:
		Current_State.IDLE:
			animation_tree["parameters/idle/blend_position"] = direction
		Current_State.WALK:
			animation_tree["parameters/Walk/blend_position"] = direction

func update_camera():
	if not camera.is_dragging and current_state == Current_State.WALK:
		camera.global_position = global_position

func update_aim():
	weapon_holder.rotation = direction.angle()

func _input(event):
	if can_move:
		input_direction = Vector2(
			Input.get_axis("move_left", "move_right"),
			Input.get_axis("move_up", "move_down")
		).normalized()
	
	if  input_direction.x != 0 or input_direction.y != 0:
		
		direction = input_direction
		
		current_state = Current_State.WALK
	else:
		current_state = Current_State.IDLE
		
	velocity = input_direction * speed

func get_player_direction()->Vector2:
	return direction

func _on_melee_area_entered(area):
	pass # Replace with function body.

func attack_check(delta:float):
	if Input.is_action_just_pressed("attack") and !attacking:
		match attack_type:
			Attack_Type.MELEE:
				var target_position :Vector2 = (melee_marker.global_position - weapon_holder.global_position).normalized()
				melee_attack(target_position)
			
			Attack_Type.SEEKER:
				var target_position :Vector2 = (get_global_mouse_position() - weapon_holder.global_position).normalized()
				magic_attack(target_position)
	
func melee_attack(target:Vector2):
	attacking = true
	weapon_zone.monitoring = true
	weapon_zone.monitorable = true
	var tween = create_tween()
	tween.tween_property(weapon_holder,"position",target*10, 0.2)
	tween.tween_callback(return_default)

func  magic_attack(target:Vector2):
	var tween = create_tween()
	tween.tween_property(weapon_holder,"position",target*100, 0.2)
	tween.tween_callback(return_default)

func return_default():
	var tween = create_tween()
	tween.tween_property(weapon_holder,"position",Vector2.ZERO, 0.2)
	await get_tree().create_timer(0.5).timeout
	attacking = false
	weapon_zone.monitoring = false
	weapon_zone.monitorable = false

func set_weapon():
	match attack_type:
			Attack_Type.MELEE:
				sprite.frame = 0
				damage = 5
			Attack_Type.SEEKER:
				sprite.frame = 3
				damage = 1
			Attack_Type.MAGIC:
				sprite.hide()
				magic.show()
				magic.enabled = true

func _on_weapon_zone_body_entered(body):
	if attacking and attack_type == Attack_Type.MELEE and body is Monster:
		print("attacking")
		body.take_damage(damage)
