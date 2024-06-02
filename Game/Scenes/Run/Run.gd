extends Node2D
@onready var board = $Board
@onready var turn_controler = $Turn_Controler

const COMBAT = preload("res://Game/Scenes/Combat/combat.tscn")
@onready var camera :Camera2D= $Camera

@onready var hp = $Top_Bar/Menu/Profile/Profile/Stats/HP
@onready var sanity = $Top_Bar/Menu/Profile/Profile/Stats/Sanity
@onready var turn_counter = $Top_Bar/Menu/Turn/Turn_Counter
@onready var actions = $Top_Bar/Menu/Game_State/Action_Tokens

const action_token_scene = preload("res://Game/Scenes/UI/action_token.tscn")


func _ready():
	Game_Manager.combat_done.connect(toggle_visiblity_on)
	
	for i in PlayerStats.player_stat.max_actions:
		var instance = action_token_scene.instantiate()
		actions.add_child(instance)
	
	Events.on_player_stats_changed.connect(_on_stats_changed)
	_on_stats_changed()


func _process(delta):
	hp.value = PlayerStats.player_stat.player_health
	sanity.value = PlayerStats.player_stat.player_sanity
	
	
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
	AudioManager.play_music(2)
	toggle_visiblity_off()
	var new_combat := COMBAT.instantiate()
	add_child(new_combat)


func toggle_visiblity_off():
	turn_controler.hide()
	board.visible =false
	board.buttons.hide()
	
func toggle_visiblity_on():
	turn_controler.show()
	board.visible =true
	board.buttons.show()
	camera.make_current()


func _on_end_turn_pressed():
	if not Game_Manager.is_player_turn:
		return
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
