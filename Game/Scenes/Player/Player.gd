class_name Player
extends CharacterBody2D

signal toggle_inventory


# Exports
@export_category("Movement")
@export var speed :int = 50
@export var max_hp : int = 10
@export var hp :int




var can_move = false
var direction : Vector2 = Vector2.UP
var input_direction :Vector2
@onready var animation_tree : AnimationTree = $Visual_Component/AnimationTree
@onready var mood : Label = $Visual_Component/Mood
@onready var interaction_component = $Interaction_Component



enum Current_State {
	IDLE,
	WALK
}

@export_category("State_Machine")
@export var current_state : Current_State = Current_State.IDLE

func _ready():
	can_move = true
	animation_tree.active = true
	hp = max_hp

func _physics_process(_delta: float) -> void :
	update_animation()
	move_and_slide()

func update_animation():
	animation_tree["parameters/conditions/idle"] = current_state == Current_State.IDLE
	animation_tree["parameters/conditions/is_moving"] = current_state == Current_State.WALK
	
	match current_state:
		Current_State.IDLE:
			animation_tree["parameters/idle/blend_position"] = direction
		Current_State.WALK:
			Game_Manager.camera_relocate.emit(global_position)
			animation_tree["parameters/Walk/blend_position"] = direction

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


func get_drop_position() ->Vector2 :
	return global_position

func get_player_direction()->Vector2:
	return direction
