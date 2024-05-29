extends Node2D

@export var board_height : int
@export var board_width : int

@export var room_template: Resource
@onready var player_token = $Player_Token

var hovered_room : Room
var rooms = []

@export_category("pLAYER_DIRECTION")
@export var player_position : Vector2
@export var new_position : Vector2

@export var player_room : Room

func _ready():
	Events.board_moved.connect(board_moved)
	Events.on_card_hovering_room_enter.connect(_on_mouse_hover_enter_room)
	Events.on_card_hovering_room_exit.connect(_on_mouse_hover_exit_room)
	
	var room_scene = load(room_template.resource_path)
	# Create rooms
	for x in board_width:
		rooms.append([])
		for y in board_height:
			create_new_room(room_scene,x,y)

	initialize_board();
	set_up_player()

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
	
	var central_room = rooms[board_width/2][board_height/2]
	central_room.openings = Game_Manager.ALL_DIRECTIONS.duplicate();
	central_room.update_visuals()
	
	update_rooms_activation()
	
	Board_Manipulator.grid = rooms;

func find_connected_rooms(room):
	var visited_rooms = []
	# Recursively find all rooms connected to the centre
	find_connected_rooms_recursive(room,visited_rooms)
	return visited_rooms

func find_connected_rooms_recursive(room, visited_rooms):
	visited_rooms.append(room)
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
				find_connected_rooms_recursive(next_room, visited_rooms)

func update_board():
	for x in rooms.size():
		for y in rooms[0].size():
			rooms[x][y].coordinates = Vector2i(x,y);
			rooms[x][y].update_visuals()
	await update_rooms_positions()
	update_rooms_activation()
	pass
	
func update_rooms_positions():
	var tweens = []
	for x in rooms.size():
		for y in rooms[0].size():
			# update position
			var room = rooms[x][y]
			var room_size = room.get_room_pixel_size();
			var new_position :Vector2 = Vector2(room_size.x * room.coordinates.x,room_size.y * room.coordinates.y);
			# skip if not moved
			if room.position == new_position:
				continue
			
			var tween = get_tree().create_tween()
			
			#wrap around in Y axis
			if abs(room.coordinates.y - room.position.y/room_size.y) > 1:
				var up = room.coordinates.y - room.position.y/room_size.y > 0
				
				if up:
					room.position = Vector2(room.position.x, room_size.y * board_height)
				else:
					room.position = Vector2(room.position.x, - room_size.y)
			
			#wrap around in X axis
			if abs(room.coordinates.x - room.position.x/room_size.x) > 1:
				var left = room.coordinates.x - room.position.x/room_size.x > 0
				
				if left:
					room.position = Vector2(room_size.x * board_width, room.position.y)
				else:
					room.position = Vector2(- room_size.x,room.position.y)
						
			
			if rooms[x][y].is_hosting_player:
				force_update_player_room(x,y)
			
			tweens.append(tween.tween_property(room, "position", new_position, 0.8).set_trans(Tween.TRANS_QUAD))
			 
	await Tween_Utilities.await_all(tweens);

func update_rooms_activation():
	var central_room = rooms[board_width/2][board_height/2]
	var active_rooms = find_connected_rooms(central_room)
	
	for row in rooms:
		for room in row:
			room.active = active_rooms.has(room)

func board_moved():
	update_board()

func _on_mouse_hover_enter_room(room : Room):
	hovered_room = room
	
func _on_mouse_hover_exit_room(room : Room):
	hovered_room = null

func set_up_player():
	player_position = Vector2.ZERO
	new_position = player_position
	update_player_token_room()

func force_update_player_room(x:int , y:int):
	player_position = Vector2(x,y)
	new_position = player_position
	update_player_token_room()
	
func update_player_token_room():
	if new_position.x >= 0 and new_position.x < rooms.size() and new_position.y >= 0 and new_position.y < rooms[new_position.x].size():
		rooms[player_position.x][player_position.y].is_hosting_player = false
		player_position = new_position
		player_token.reparent(rooms[player_position.x][player_position.y])
		player_token.global_position = rooms[player_position.x][player_position.y].global_position
		player_room = rooms[player_position.x][player_position.y]
		rooms[player_position.x][player_position.y].is_hosting_player = true
	else :
		new_position = player_position
	
	Game_Manager.camera_relocate.emit(player_token.global_position)

func _on_up_pressed():
	new_position = player_position
	new_position += Vector2.UP
	update_player_token_room()


func _on_left_pressed():
	new_position = player_position
	new_position +=Vector2.LEFT
	update_player_token_room()


func _on_r_ight_pressed():
	new_position = player_position
	new_position += Vector2.RIGHT
	update_player_token_room()


func _on_down_pressed():
	new_position = player_position
	new_position += Vector2.DOWN
	update_player_token_room()
