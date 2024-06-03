extends CanvasLayer

@onready var _load_game_dlg = $LoadGameDlg

func _ready():
	%Score.text = "score: %s" % Game_Manager.score
	await Leaderboards.post_guest_score(Game_Manager.leaderboard_Id, Game_Manager.score, Game_Manager.player_name)
func _on_load_btn_pressed():
	_load_game_dlg.show_modal()


func _on_main_menu_btn_pressed():
	TransitionMgr.transition_to("res://scenes/ui/title.tscn")
	visible = false
