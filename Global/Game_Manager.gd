extends Node

var seed = hash("help_me!!!")
var RNG : RandomNumberGenerator;

const leaderboard_Id = "living-board-highscores-ZXro"

var player_name = ""

var storyTelled = false

signal camera_relocate(pos:Vector2)

signal leave_room

signal combat_room_entered(enemies : Array[Monster_Data])
signal treasure_room_entered()
signal hazard_room_entered()

const z_index_idle_card = 0
const z_index_dragging_card = 10
const z_index_rooms = 20

var monsters_alive := 0

var turn: int = 0
var score :int = 0
var is_player_turn = true

var ai_moves: int = 3
func _ready():
	RNG = RandomNumberGenerator.new()
	#RNG.seed = seed;

func add_score(temp_score:int)->void:
	score+= temp_score
	if score<=0:
		score = 0

func reset():
	turn = 0
	score = 0
	is_player_turn = true
