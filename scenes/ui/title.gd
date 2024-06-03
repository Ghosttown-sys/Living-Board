extends Control

@onready var _load_game_dlg = $LoadGameDlg

func _ready():
	AudioManager.play_music(0)

func _on_NewGameBtn_pressed():
	AudioManager.button_press_sfx.play()
	if Game_Manager.player_name == "":
		pass
	else:
		Game_Manager.storyTelled = false
		GameStateService.new_game()
		TransitionMgr.transition_to("res://Game/Scenes/Run/Run.tscn")


func _on_LoadGameBtn_pressed():
	AudioManager.button_press_sfx.play()
	_load_game_dlg.show_modal()

func _on_LeaderboardBtn_pressed():
	AudioManager.button_press_sfx.play()
	get_tree().change_scene_to_file("res://scenes/ui/leaderboard.tscn")

func _on_ExitBtn_pressed():
	AudioManager.button_press_sfx.play()
	get_tree().quit()


func _on_credits_btn_pressed():
	AudioManager.button_press_sfx.play()
	get_tree().change_scene_to_file("res://scenes/ui/credits.tscn")
