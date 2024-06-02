extends Node2D

const MONSTER = preload("res://Game/Scenes/Monster/monster.tscn")

var current_enemies : Array[Monster_Data]

var monster_array = []

func _ready():
	Game_Manager.monsters_alive = 0
	set_up_possible_spawn_list()
	for i in range(1,monster_array.size()+1):
		monster_array[i-1] = MONSTER.instantiate()
		monster_array[i-1].monster_data = current_enemies.pick_random()
		monster_array[i-1].global_position = get_node("Spawner_" + str(randi_range(1,4))).global_position
		add_child(monster_array[i-1])
		Game_Manager.monsters_alive +=1

func set_up_possible_spawn_list():
	for i in range(Game_Manager.turn+3):
		monster_array.append(null)

func _process(delta):
	if Game_Manager.monsters_alive == 0:
		combat_done()

func combat_done():
	AudioManager.play_music(1)
	Game_Manager.combat_done.emit()
	queue_free()
