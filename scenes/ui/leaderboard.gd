extends Control

func _on_back_btn_pressed():
		AudioManager.button_press_sfx.play()
		get_tree().change_scene_to_file("res://scenes/ui/title.tscn")
