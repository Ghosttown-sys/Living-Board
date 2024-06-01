extends Node

var seed = hash("help_me")
var RNG : RandomNumberGenerator;

enum DIRECTION {LEFT = 270, RIGHT = 90, UP = 0, DOWN = 180}

const ALL_DIRECTIONS : Array[DIRECTION] = [\
		DIRECTION.LEFT,\
		DIRECTION.RIGHT,\
		DIRECTION.UP,\
		DIRECTION.DOWN] 

# Converts directions to vector2i
const d2v = {
	DIRECTION.LEFT : Vector2i.LEFT,
	DIRECTION.RIGHT : Vector2i.RIGHT,
	DIRECTION.UP : Vector2i.UP,
	DIRECTION.DOWN : Vector2i.DOWN
}
# Maps opposite directions
const opposite_direction = {
	DIRECTION.LEFT :DIRECTION.RIGHT,
	DIRECTION.RIGHT :DIRECTION.LEFT,
	DIRECTION.UP :DIRECTION.DOWN,
	DIRECTION.DOWN :DIRECTION.UP
}

const layer_index = {
	DIRECTION.LEFT :0,
	DIRECTION.RIGHT :1,
	DIRECTION.UP :2,
	DIRECTION.DOWN :3
}

const direction_index = {
	0: DIRECTION.LEFT ,
	1: DIRECTION.RIGHT ,
	2: DIRECTION.UP ,
	3: DIRECTION.DOWN
}
# true = clockwise, false = anticlockwise
# Returns the direction after performing a rotation
func get_dir_after_rotation(initial_dir, rotation) -> DIRECTION:
	var dirs = [DIRECTION.UP, DIRECTION.RIGHT, DIRECTION.DOWN, DIRECTION.LEFT]
	var rotation_dir = 1 if rotation else -1
	var index = dirs.find(initial_dir)
	return dirs[(index + rotation_dir) % dirs.size()]

signal camera_relocate(pos:Vector2)

const z_index_idle_card = 0
const z_index_dragging_card = 10
const z_index_rooms = 20

func _ready():
	RNG = RandomNumberGenerator.new()
	RNG.seed = seed;
