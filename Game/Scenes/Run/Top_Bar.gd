extends CanvasLayer

@onready var sprite = $Menu/Profile/Profile/Avatar_holder/Weapon_Holder/Sprite
@onready var magic = $Menu/Profile/Profile/Avatar_holder/Weapon_Holder/magic
const GET_SCORE = preload("res://Game/Core/Score_Card/get_score.tscn")
@onready var score_board = $ScrollContainer/Score_Board


@export_category("Attack_Type")
@export var attack_type : Player_Stats_Res.Attack_Type = Player_Stats_Res.Attack_Type.MELEE



var player_stats: Player_Stats_Res

func _on_pause_button_pressed():
	Events.pause_menu_requested.emit("pause")

func _ready():
	Events.add_score.connect(add_score)
	player_stats = PlayerStats.player_stat


func _process(delta):
	set_weapon()

func add_score(score:int):
	var new_score = GET_SCORE.instantiate()
	new_score.score = score
	score_board.add_child(new_score)
	

func set_weapon():
	attack_type = player_stats.attack_type
	match attack_type:
			Player_Stats_Res.Attack_Type.MELEE:
				sprite.frame = 0
				magic.hide()
				
			Player_Stats_Res.Attack_Type.SEEKER:
				sprite.frame = 3
				magic.hide()
				
				
			Player_Stats_Res.Attack_Type.RANGED:
				sprite.rotation = deg_to_rad(180)
				sprite.frame = 1
				magic.hide()
				
			Player_Stats_Res.Attack_Type.MAGIC:
				sprite.hide()
				magic.show()
