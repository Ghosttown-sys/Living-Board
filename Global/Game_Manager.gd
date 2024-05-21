extends Node

enum DIRECTION {LEFT = 0, RIGHT = 1, UP = 2, DOWN = 3}

const ALL_DIRECTIONS : Array[Game_Manager.DIRECTION] = [\
		Game_Manager.DIRECTION.LEFT,\
		Game_Manager.DIRECTION.RIGHT,\
		Game_Manager.DIRECTION.UP,\
		Game_Manager.DIRECTION.DOWN] 

# Converts directions to vector2i
const d2v = {
	Game_Manager.DIRECTION.LEFT : Vector2i.LEFT,
	Game_Manager.DIRECTION.RIGHT : Vector2i.RIGHT,
	Game_Manager.DIRECTION.UP : Vector2i.UP,
	Game_Manager.DIRECTION.DOWN : Vector2i.DOWN
}
# Maps opposite directions
const opposite_direction = {
	Game_Manager.DIRECTION.LEFT :Game_Manager.DIRECTION.RIGHT,
	Game_Manager.DIRECTION.RIGHT :Game_Manager.DIRECTION.LEFT,
	Game_Manager.DIRECTION.UP :Game_Manager.DIRECTION.DOWN,
	Game_Manager.DIRECTION.DOWN :Game_Manager.DIRECTION.UP
}

signal camera_relocate(pos:Vector2)
