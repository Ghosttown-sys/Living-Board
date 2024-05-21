extends Node2D

@export var board_height : int
@export var board_width : int

@export var room_template: Resource

var rooms = {}

func _ready():
	var room_scene = load(room_template.resource_path)
	for x in board_height:
		for y in board_width:
			create_new_room(room_scene,x,y)
	initialize_board();

func create_new_room(room_scene,x, y):
	# Create the room
	var room_instance = room_scene.instantiate();
	add_child(room_instance)
	room_instance.coordinates = Vector2i(x,y)
	# Position it on the grid
	var room_size = room_instance.get_room_pixel_size()
	room_instance.position = Vector2(room_size.x * x,room_size.y * y);
	
	rooms[Vector2i(x,y)] = room_instance;

func initialize_board():
	var visited_rooms = []
	var central_room = rooms[Vector2i(board_width/2,board_height/2)]
	central_room.openings = Game_Manager.ALL_DIRECTIONS.duplicate();
	central_room.update_visuals()
	
	find_connected_rooms(central_room,visited_rooms)

func find_connected_rooms(room, visited_rooms):
	
	visited_rooms.append(room)
	room.modulate = Color.AQUA
	
	for direction in room.openings:
		var next_room_coordinates = room.coordinates + Game_Manager.d2v[direction];
		# Check if it's out of bound
		if next_room_coordinates.x >= board_width || next_room_coordinates.y >= board_height\
		 || next_room_coordinates.x < 0 || next_room_coordinates.y < 0:
			return
		
		var next_room = rooms[next_room_coordinates];
		# if both ways are connected and was not visited yet, perform the recursion
		if not visited_rooms.has(next_room) && next_room.openings.has(Game_Manager.opposite_direction[direction]):
			find_connected_rooms(next_room, visited_rooms)
