class_name Score
extends Label

@export var score :int = 0

func _ready():
	if score >=0:
		text = "score + " + str(score)
	else :
		modulate = Color.RED
		text = "score " + str(score)
	await get_tree().create_timer(0.1).timeout
	Game_Manager.add_score(score)
	await get_tree().create_timer(3).timeout
	queue_free()
