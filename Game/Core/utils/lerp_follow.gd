extends Node2D

@export var to_follow : Node2D
@export var follow_position_speed : float;
@export var follow_rotation_speed : float;

var rotationDelta : Vector2

func  _ready():
	global_position = to_follow.global_position;
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	global_position = global_position.lerp(to_follow.global_position, delta * follow_position_speed)
	
	var movement = global_position - to_follow.global_position
	rotationDelta = rotationDelta.lerp(movement, delta * follow_rotation_speed)

	rotation_degrees = -clamp(rotationDelta.x,-60,60)