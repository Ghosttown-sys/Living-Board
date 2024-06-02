extends Node
class_name Directions

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
	DIRECTION.LEFT :3,
	DIRECTION.RIGHT :1,
	DIRECTION.UP :0,
	DIRECTION.DOWN :2
}

const direction_index = {
	3: DIRECTION.LEFT ,
	1: DIRECTION.RIGHT ,
	0: DIRECTION.UP ,
	2: DIRECTION.DOWN
}

# true = clockwise, false = anticlockwise
# Returns the direction after performing a rotation
func get_dir_after_rotation(initial_dir, rotation) -> DIRECTION:
	var dirs = [DIRECTION.UP, DIRECTION.RIGHT, DIRECTION.DOWN, DIRECTION.LEFT]
	var rotation_dir = 1 if rotation else -1
	var index = dirs.find(initial_dir)
	return dirs[(index + rotation_dir) % dirs.size()]
