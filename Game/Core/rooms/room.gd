extends Node2D
class_name room

var active : bool
# rotation/ facing towards
var direction : Game_Manager.DIRECTION
# which directions have a corridor
var openings : Array[Game_Manager.DIRECTION]
# which other rooms this is connected to
var connections = {}
# coordinates in the grid
var coordinates : Vector2i;

@onready var tilemap : TileMap = $Room_Tilemap

func _ready():
	assign_random_openings()
	update_visuals()

func update_visuals():
	# for each layer corridor of the tilemap
	for direction in range(1,5):
		tilemap.set_layer_enabled(direction, openings.has(direction - 1));

func get_room_pixel_size():
	return tilemap.get_used_rect().size * tilemap.rendering_quadrant_size

func assign_random_openings():
	var directions : Array[Game_Manager.DIRECTION] = Game_Manager.ALL_DIRECTIONS.duplicate()
	for i in range(randi() % directions.size()):
		var index = randi() % directions.size()
		directions.remove_at(index)
	
	openings = directions;
