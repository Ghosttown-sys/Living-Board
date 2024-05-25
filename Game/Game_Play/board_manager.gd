extends Node2D

@export var board_height : int
@export var board_width : int

@export var room_template: Resource
var rooms = []

func _ready():
	var room_scene = load(room_template.resource_path)
	for x in board_width:
		rooms.append([])
		for y in board_height:
			create_new_room(room_scene,x,y)
	initialize_board();

func create_new_room(room_scene,x, y):
	# Create the room
	var room_instance = room_scene.instantiate();
	room_instance.room_id = room_instance.static_id + 1;
	rooms[x].append(room_instance)
	add_child(room_instance)
	room_instance.active = false
	room_instance.coordinates = Vector2i(x,y)
	# Position it on the grid
	var room_size = room_instance.get_room_pixel_size()
	room_instance.position = Vector2(room_size.x * x,room_size.y * y);
	

func initialize_board():
	var visited_rooms = []
	var central_room = rooms[board_width/2][board_height/2]
	central_room.openings = Game_Manager.ALL_DIRECTIONS.duplicate();
	central_room.update_visuals()
	
	# Recursively find all rooms connected to the centre
	find_connected_rooms(central_room,visited_rooms)
	
	Board_Manipulator.grid = rooms;
	

func find_connected_rooms(room, visited_rooms):
	visited_rooms.append(room)
	room.active = true
	for direction in room.openings:
		var next_room_coordinates = room.coordinates + Game_Manager.d2v[direction];
		# Check if it's out of bound
		if next_room_coordinates.x >= board_width || next_room_coordinates.y >= board_height\
		 || next_room_coordinates.x < 0 || next_room_coordinates.y < 0:
			continue
		var next_room = rooms[next_room_coordinates.x][next_room_coordinates.y];
		if next_room.openings.has(Game_Manager.opposite_direction[direction]):
			# Disable fog between corridors if both ways are connected
			room.enable_corridor_fog(direction, false)
			next_room.enable_corridor_fog(Game_Manager.opposite_direction[direction], false)

			# if it was not visited yet, perform the recursion
			if not visited_rooms.has(next_room):
				find_connected_rooms(next_room, visited_rooms)

func update_board():
	for x in rooms.size():
		for y in rooms[0].size():
			rooms[x][y].coordinates = Vector2i(x,y);
			rooms[x][y].update_visuals()
	update_rooms_positions()
	pass
	
func update_rooms_positions():
	for x in rooms.size():
		for y in rooms[0].size():
			var tween = get_tree().create_tween()
			# update position
			var room = rooms[x][y]
			var room_size = room.get_room_pixel_size();
			var new_position :Vector2 = Vector2(room_size.x * room.coordinates.x,room_size.y * room.coordinates.y);
			tween.tween_property(room, "position", new_position, 0.8).set_trans(Tween.TRANS_QUAD)

func Push_Left():
	Board_Manipulator.push_row(0,Game_Manager.DIRECTION.LEFT)
	Board_Manipulator.print_grid()
	update_board()

func Push_Right():
	Board_Manipulator.push_row(0,Game_Manager.DIRECTION.RIGHT)
	Board_Manipulator.print_grid()
	update_board()
