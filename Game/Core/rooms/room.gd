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
"""
Tilemap layers are:
	0 : Base
	
	1 : Left_Corridor
	2 : Right_Corridor
	3 : Top_Corridor
	4 : Bottom_Corridor
	
	5 : Left_Fog
	6 : Right_Fog
	7 : Top_Fog
	8 : Bottom_Fog
"""


func _ready():
	assign_random_openings()
	update_visuals()

func update_visuals():
	# for layers 1 to 4 (corridor layers)
	for direction in range(1,5):
		tilemap.set_layer_enabled(direction, openings.has(direction - 1));

func get_room_pixel_size():
	return tilemap.get_used_rect().size * tilemap.rendering_quadrant_size
	
# At start, assign random openings to the room
func assign_random_openings():
	var directions : Array[Game_Manager.DIRECTION] = Game_Manager.ALL_DIRECTIONS.duplicate()
	for i in range(randi() % directions.size()):
		var index = randi() % directions.size()
		directions.remove_at(index)
	
	openings = directions;

# Renders or hide the fog between corridors
func enable_corridor_fog(direction : Game_Manager.DIRECTION, enabled : bool):
	var fog_layer = direction + 5;
	tilemap.set_layer_enabled(fog_layer, enabled);
