extends Node2D
@onready var board = $Board
@onready var turn_controler = $Turn_Controler

const COMBAT = preload("res://Game/Scenes/Rooms_Internal/combat.tscn")
const TREASURE = preload("res://Game/Scenes/Rooms_Internal/treasure.tscn")

const GAME_OVER = preload("res://scenes/ui/game_over.tscn")
const VICTORY = preload("res://scenes/ui/win.tscn")

@onready var camera :Camera2D= $Camera

@onready var hp = $Top_Bar/Menu/Profile/Profile/Stats/HP
@onready var sanity = $Top_Bar/Menu/Profile/Profile/Stats/Sanity
@onready var turn_counter = $Top_Bar/Menu/Turn/Turn_Counter
@onready var actions = $Top_Bar/Menu/Game_State/Action_Tokens
@onready var room_interactions = $Room_Interactions

const action_token_scene = preload("res://Game/Scenes/UI/action_token.tscn")

var current_enemies : Array[Monster_Data]
@onready var shaker = $Shaker

func _ready():
	Game_Manager.leave_room.connect(toggle_visiblity_on)
	Game_Manager.combat_room_entered.connect(combat_room_found)
	Game_Manager.treasure_room_entered.connect(treasure_room_found)
	Game_Manager.hazard_room_entered.connect(hazard_room_found)
	
	Events.player_died.connect(game_over)
	Events.victory.connect(victory)
	Events.on_move_finished.connect(on_move_finished)
	Events.on_game_started.emit()
	var current_enemies : Array[Monster_Data]

	for i in PlayerStats.player_stat.max_actions:
		var instance = action_token_scene.instantiate()
		actions.add_child(instance)
	
	
	PlayerStats.reset_player()
	Events.on_player_stats_changed.connect(_on_stats_changed)
	_on_stats_changed()

func on_move_finished():
	if PlayerStats.player_stat.player_actions <= 0:
		await get_tree().create_timer(1).timeout
		end_turn()
		
func _process(delta):
	hp.value = PlayerStats.player_stat.player_health
	sanity.value = PlayerStats.player_stat.player_sanity
	
func combat_room_found(enemies : Array[Monster_Data]):
	current_enemies = enemies
	room_interactions.show()
	
func treasure_room_found():
	toggle_visiblity_off()
	var new_treasure := TREASURE.instantiate()
	add_child(new_treasure)

func hazard_room_found():
	PlayerStats.take_damage(10)

func _on_stats_changed():
	for token in actions.get_children():
		token.visible = false
	for i in PlayerStats.player_stat.player_actions:
		actions.get_child(i).visible = true	
	
	hp.max_value = PlayerStats.player_stat.max_hp
	sanity.max_value = PlayerStats.player_stat.max_sanity
	
	turn_counter.text = "Turn: %s" % Game_Manager.turn

func _on_button_pressed():
	if not Game_Manager.is_player_turn:
		return
	
	AudioManager.button_press_sfx.play()
	match board.player_room.room_type:
		Room.ROOM_TYPE.Combat:
			AudioManager.play_music(2)
			toggle_visiblity_off()
			var new_combat := COMBAT.instantiate()
			new_combat.current_enemies = current_enemies
			add_child(new_combat)
			

func toggle_visiblity_off():
	turn_controler.hide()
	board.visible =false
	board.buttons.hide()
	room_interactions.hide()
	
func toggle_visiblity_on():
	turn_controler.show()
	board.visible =true
	board.buttons.show()
	camera.make_current()

func end_turn():
	if not Game_Manager.is_player_turn:
		return
	shaker.apply_random_shake()
	board_random_moves()
	PlayerStats.restore_all_actions()

func board_random_moves():
	Game_Manager.is_player_turn = false
	for i in Game_Manager.ai_moves:
		# push col, row ro rotate
		var move = Game_Manager.RNG.randi() % 3
		var random_x = Game_Manager.RNG.randi() % Board_Manipulator.grid_height
		var random_y = Game_Manager.RNG.randi() % Board_Manipulator.grid_width
		match move:
			0: #push col
				var possible_dirs = [Directions.DIRECTION.UP, Directions.DIRECTION.DOWN]
				var random_dir = possible_dirs.pick_random()
				Board_Manipulator.push_column(random_x, random_dir)
			1: #push row
				var possible_dirs = [Directions.DIRECTION.LEFT, Directions.DIRECTION.RIGHT]
				var random_dir = possible_dirs.pick_random()
				Board_Manipulator.push_row(random_y, random_dir)
			2: #rotate
				var possible_dirs = [Directions.DIRECTION.LEFT, Directions.DIRECTION.RIGHT]
				var random_dir = possible_dirs.pick_random()
				Board_Manipulator.rotate_room(Vector2i(random_x,random_y),random_dir)
		await get_tree().create_timer(1).timeout
	Game_Manager.is_player_turn = true
	Game_Manager.turn += 1
	_on_stats_changed()


func _on_skip_room_pressed():
	AudioManager.button_press_sfx.play()
	PlayerStats.player_stat.player_sanity -= 20
	room_interactions.hide()
	Events.on_move_finished.emit()
	
func game_over():
	AudioManager.play_music(3)
	var game_over_scene = GAME_OVER.instantiate()
	add_child(game_over_scene)

func victory():
	AudioManager.play_music(4)
	var victory_scene = VICTORY.instantiate()
	add_child(victory_scene)
