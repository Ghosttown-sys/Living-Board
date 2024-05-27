extends Node2D

@export var to_follow : Node2D
@export var follow_position_speed : float = 8
@export var follow_rotation_speed : float = 4

var rotationDelta : Vector2

func  _ready():
	global_position = to_follow.global_position;

func _process(delta):
	position = position.lerp(to_follow.position, delta * follow_position_speed)
	var movement = position - to_follow.position
	rotationDelta = rotationDelta.lerp(movement , delta * follow_rotation_speed)
	rotation_degrees = -clamp(rotationDelta.x,-60,60) + to_follow.rotation_degrees
