extends Node2D

@export var board_height : int
@export var board_width : int

@export var room_template: Resource
@onready var player_token = $Player_Token

var hovered_room : Room
var rooms = []

@export_category("PLAYER_DIRECTION")
@export var player_position : Vector2
@export var new_position : Vector2

@export var player_room : Room
@onready var buttons = $Buttons

func _ready():
	AudioManager.play_music(1)
	AudioManager.game_start_sfx.play()
	
	Events.board_moved.connect(board_moved)
	Events.on_card_hovering_room_enter.connect(_on_mouse_hover_enter_room)
	Events.on_card_hovering_room_exit.connect(_on_mouse_hover_exit_room)
	
	var room_scene = load(room_template.resource_path)
	# Create rooms
	for x in board_width:
		rooms.append([])
		for y in board_height:
			create_new_room(room_scene,x,y)
	
	player_room = rooms[0][0]
	initialize_board();
	set_up_player()

func _process(delta):
	if player_room != null:
		player_token.rotation = -player_room.rotation

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
	player_room.openings = Directions.ALL_DIRECTIONS.duplicate();
	player_room.update_visuals()
	
	update_rooms_activation()
	
	Board_Manipulator.grid = rooms;
	
# Returns a list of all rooms connected to the room
func get_connected_rooms(room: Room):
	var connected_rooms = []
	for direction in room.get_rotated_openings():
		var neighbour_coordinates = room.coordinates + Directions.d2v[direction];
		# Check if it's out of bound
		if neighbour_coordinates.x >= board_width || neighbour_coordinates.y >= board_height\
		 || neighbour_coordinates.x < 0 || neighbour_coordinates.y < 0:
			continue
		var neighbour = rooms[neighbour_coordinates.x][neighbour_coordinates.y]
		if neighbour.get_rotated_openings().has(Directions.opposite_direction[direction]):
			connected_rooms.append(neighbour)
	
	return connected_rooms
	
func find_all_connected_rooms(room : Room):
	var visited_rooms = []
	# Recursively find all rooms connected to the centre
	find_connected_rooms_recursive(room,visited_rooms)
	return visited_rooms

func find_connected_rooms_recursive(room, visited_rooms):
	visited_rooms.append(room)
	for direction in room.get_rotated_openings():
		var next_room_coordinates = room.coordinates + Directions.d2v[direction];
		# Check if it's out of bound
		if next_room_coordinates.x >= board_width || next_room_coordinates.y >= board_height\
		 || next_room_coordinates.x < 0 || next_room_coordinates.y < 0:
			room.enable_corridor_fog(direction, true)
			continue
		var next_room = rooms[next_room_coordinates.x][next_room_coordinates.y];
		
		if next_room.get_rotated_openings().has(Directions.opposite_direction[direction]):
			# Disable fog between corridors if both ways are connected
			room.enable_corridor_fog(direction, false)
			next_room.enable_corridor_fog(Directions.opposite_direction[direction], false)
			
			# if it was not visited yet, perform the recursion
			if not visited_rooms.has(next_room):
				find_connected_rooms_recursive(next_room, visited_rooms)
		else:
			room.enable_corridor_fog(direction, true)

func update_board():
	for x in rooms.size():
		for y in rooms[0].size():
			rooms[x][y].coordinates = Vector2i(x,y);
			rooms[x][y].update_visuals()
	await update_rooms_positions()
	update_rooms_rotation()
	update_rooms_activation()
	
func update_rooms_rotation():
	for x in rooms.size():
		for y in rooms[0].size():
			# update rotation
			var room = rooms[x][y]
			var new_rotation = room.direction
			
			if room.rotation_degrees == new_rotation:
				continue
			
			# If the rotation is 0, make it 360 to rotate anticlockwise
			if room.rotation_degrees ==0 and new_rotation == Directions.DIRECTION.LEFT:
				room.rotation_degrees = 360
			
			# If the rotation is 270, make it -90 to rotate clockwise
			if room.rotation_degrees == 270 and new_rotation == Directions.DIRECTION.UP:
				room.rotation_degrees = -90
			
			AudioManager.wall_move_sfx.play()
			#rotate
			var tween = get_tree().create_tween()
			await tween.tween_property(room, "rotation_degrees", new_rotation, 0.8).set_trans(Tween.TRANS_QUAD).finished
			
	
# Visually moves the rooms positions in the grid
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
				
			var tween = get_tree().create_tween()
			tweens.append(tween.tween_property(room, "position", new_position, 0.8).set_trans(Tween.TRANS_QUAD))
	if tweens.size() > 0:
		AudioManager.wall_move_sfx.play()
	await Tween_Utilities.await_all(tweens);

func update_rooms_activation():
	var active_rooms = find_all_connected_rooms(player_room)
	
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
	room_move_token()

func force_update_player_room(x:int , y:int):
	player_position = Vector2(x,y)
	new_position = player_position
	room_move_token()
	
func update_player_token_room():
	
	rooms[player_position.x][player_position.y].is_hosting_player = false
	player_position = new_position
	player_token.reparent(rooms[player_position.x][player_position.y])
	
	player_room = rooms[player_position.x][player_position.y]
	rooms[player_position.x][player_position.y].is_hosting_player = true
	
	Game_Manager.camera_relocate.emit(rooms[player_position.x][player_position.y].global_position)

func room_move_token():
	update_player_token_room()
	player_token.global_position = rooms[player_position.x][player_position.y].global_position
	
func player_move_token():
	if is_valid_move():
		AudioManager.footstepo_sfx.play()
		update_player_token_room()
		var tween = get_tree().create_tween()
		tween.tween_property(player_token, "global_position", rooms[player_position.x][player_position.y].global_position, 0.8).set_trans(Tween.TRANS_QUAD)

	

# Check if the move to the next room is valid
func is_valid_move() -> bool:
	# Out of bounds
	var valid_rooms = [player_room]
	if new_position.x >= board_width || new_position.y >= board_height\
			 || new_position.x < 0 || new_position.y < 0:
				return false
	var new_room = rooms[new_position.x][new_position.y]
	var player_room = rooms[player_position.x][player_position.y]
	valid_rooms.append_array(get_connected_rooms(player_room))
	
	return valid_rooms.has(new_room)

func _on_up_pressed():
	new_position = player_position
	new_position += Vector2.UP
	player_move_token()


func _on_left_pressed():
	new_position = player_position
	new_position +=Vector2.LEFT
	player_move_token()


func _on_r_ight_pressed():
	new_position = player_position
	new_position += Vector2.RIGHT
	player_move_token()


func _on_down_pressed():
	new_position = player_position
	new_position += Vector2.DOWN
	player_move_token()


