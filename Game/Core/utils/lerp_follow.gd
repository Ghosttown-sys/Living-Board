extends Control

@export var to_follow : Control
@export var follow_position_speed : float;
@export var follow_rotation_speed : float;

var rotationDelta : Vector2

func  _ready():
	global_position = to_follow.global_position;
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position = position.lerp(to_follow.position, delta * follow_position_speed)
	var movement = position - to_follow.position
	rotationDelta = rotationDelta.lerp(movement , delta * follow_rotation_speed)
	rotation_degrees = -clamp(rotationDelta.x,-60,60)
