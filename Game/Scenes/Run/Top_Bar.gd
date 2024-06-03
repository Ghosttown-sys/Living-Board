extends CanvasLayer

@onready var sprite = $Menu/Profile/Profile/Avatar_holder/Weapon_Holder/Sprite
@onready var magic = $Menu/Profile/Profile/Avatar_holder/Weapon_Holder/magic


@export_category("Attack_Type")
@export var attack_type : Player_Stats_Res.Attack_Type = Player_Stats_Res.Attack_Type.MELEE



var player_stats: Player_Stats_Res

func _on_pause_button_pressed():
	Events.pause_menu_requested.emit("pause")

func _ready():
	player_stats = PlayerStats.player_stat

func _process(delta):
	set_weapon()


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
