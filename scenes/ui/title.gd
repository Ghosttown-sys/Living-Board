extends Control

@onready var _load_game_dlg = $LoadGameDlg
@onready var name_popup = $Insert_name

func _ready():
	AudioManager.play_music(0)
	name_popup.visible = false

func _on_NewGameBtn_pressed():
	AudioManager.button_press_sfx.play()
	if Game_Manager.player_name == "":
		name_popup.visible = true
	else:
		start_game()

func start_game():
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

func on_name_selected():
	start_game()
