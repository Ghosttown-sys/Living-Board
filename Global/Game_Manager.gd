extends Node

var seed = hash("help_me!!!")
var RNG : RandomNumberGenerator;

var storyTelled = false

signal camera_relocate(pos:Vector2)
signal combat_done

const z_index_idle_card = 0
const z_index_dragging_card = 10
const z_index_rooms = 20

var monsters_alive := 0

func _ready():
	RNG = RandomNumberGenerator.new()
	#RNG.seed = seed;
