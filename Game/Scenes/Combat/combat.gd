extends Node2D

const MONSTER = preload("res://Game/Scenes/Monster/monster.tscn")

func _ready():
	var monster_array = [null,null,null,null]
	for i in range(1,monster_array.size()+1):
		monster_array[i-1] = MONSTER.instantiate()
		monster_array[i-1].global_position = get_node("Spawner_" + str(i)).global_position
		add_child(monster_array[i-1])
		
	
	
