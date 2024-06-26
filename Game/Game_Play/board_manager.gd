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

var player_animating : bool = false

var can_move := true

func _ready():
	AudioManager.play_music(1)
	AudioManager.game_start_sfx.play()
	
	Events.board_moved.connect(board_moved)
	Events.on_card_hovering_room_enter.connect(_on_mouse_hover_enter_room)
	Events.on_card_hovering_room_exit.connect(_on_mouse_hover_exit_room)
	Game_Manager.leave_room.connect(_enemies_defeated)
	
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
	room_instance.room_id = room_instance.static_id + 1
	rooms[x].append(room_instance)
	add_child(room_instance)
	room_instance.initiate()
	room_instance.active = false
	room_instance.coordinates = Vector2i(x,y)
	# Position it on the grid
	var room_size = room_instance.get_room_pixel_size()
	room_instance.position = Vector2(room_size.x * x,room_size.y * y)

func initialize_board():
	player_room.openings = Directions.ALL_DIRECTIONS.duplicate();
	player_room.force_to_normal_room()
	
	rooms.pick_random().pick_random().force_to_exit()
	
	Board_Manipulator.grid = rooms;
	update_rooms_activation()
	
	
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
	var active_rooms = Board_Manipulator.find_all_connected_rooms(player_room)
	
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
	
	await get_tree().create_timer(0.2).timeout
	Game_Manager.camera_relocate.emit(rooms[player_position.x][player_position.y].global_position)

func room_move_token():
	update_player_token_room()
	player_token.global_position = rooms[player_position.x][player_position.y].global_position
	
func player_move_token():
	if is_valid_move():
		if not Game_Manager.is_player_turn or not PlayerStats.consume_action():
			return
		AudioManager.footstepo_sfx.play()
		update_player_token_room()
		var tween = get_tree().create_tween()
		
		player_animating = true
		await tween.tween_property(player_token, "global_position", rooms[player_position.x][player_position.y].global_position, 0.8).set_trans(Tween.TRANS_QUAD).finished
		player_animating = false
		if player_room.room_type == Room.ROOM_TYPE.Combat:
			Game_Manager.combat_room_entered.emit(player_room.hosting_monsters)
		elif player_room.room_type == Room.ROOM_TYPE.Treasure:
			Game_Manager.treasure_room_entered.emit()
		elif player_room.room_type == Room.ROOM_TYPE.Hazard:
			Game_Manager.hazard_room_entered.emit()
			Events.on_move_finished.emit()
		elif player_room.room_type == Room.ROOM_TYPE.Exit:
			Events.victory.emit()
		else:
			Events.on_move_finished.emit()

	

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

#func _input(event):
	#if player_animating:
		#return
	#if event.is_action("move_left") and !event.is_echo() and event.is_pressed():
		#_on_left_pressed()
	#if event.is_action("move_up") and !event.is_echo() and event.is_pressed():
		#_on_up_pressed()
	#if event.is_action("move_right") and !event.is_echo() and event.is_pressed():
		#_on_r_ight_pressed()
	#if event.is_action("move_down") and !event.is_echo() and event.is_pressed():
		#_on_down_pressed()

func _on_up_pressed():
	AudioManager.button_press_sfx.play()
	new_position = player_position
	new_position += Vector2.UP
	player_move_token()


func _on_left_pressed():
	AudioManager.button_press_sfx.play()
	new_position = player_position
	new_position +=Vector2.LEFT
	player_move_token()


func _on_r_ight_pressed():
	AudioManager.button_press_sfx.play()
	new_position = player_position
	new_position += Vector2.RIGHT
	player_move_token()


func _on_down_pressed():
	AudioManager.button_press_sfx.play()
	new_position = player_position
	new_position += Vector2.DOWN
	player_move_token()

func _enemies_defeated():
	player_room.monsters_defeated()
