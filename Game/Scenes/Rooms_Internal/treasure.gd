extends Node2D

@onready var stairs = $Stairs_Collider
@onready var treasure = $Treasure_Collider
@onready var player = $Player

var stair_coord : Array[Vector2] = [Vector2(550,265),Vector2(600,265),Vector2(650,265),Vector2(700,265)]
var treasure_coord : Array[Vector2] = [Vector2(480,290),Vector2(580,290),Vector2(580,360),Vector2(480,360)]

func _ready():
	$Stairs_Collider.global_position = stair_coord.pick_random()
	$Treasure_Collider.global_position = treasure_coord.pick_random()
	$Camp_FIre/fire.play("default")

func _on_stairs_collider_body_entered(body):
	Events.add_score.emit(20)
	Game_Manager.leave_room.emit()
	Events.on_move_finished.emit()
	queue_free()


func _on_treasure_collider_body_entered(body):
	player.can_move = false
	player.input_direction = Vector2.ZERO
	$Treasure_Collider.set_deferred("monitorable",false)
	$Treasure_Collider.set_deferred("monitoring",false)
	$POP_UP.show()
	var random_number = randi_range(1,4)
	if random_number == 1:
		$POP_UP/Weapon_container/Sword.visible = true
	elif random_number == 2:
		$POP_UP/Weapon_container/Bow.visible = true
	elif random_number == 3:
		$POP_UP/Weapon_container/Seeker.visible = true
	elif random_number == 4:
		$POP_UP/Weapon_container/Magic.visible = true
		


func _on_sword_pressed():
	PlayerStats.player_stat.attack_type = Player_Stats_Res.Attack_Type.MELEE
	player.can_move= true
	player.set_weapon()
	$POP_UP.hide()


func _on_bow_pressed():
	PlayerStats.player_stat.attack_type = Player_Stats_Res.Attack_Type.RANGED
	player.can_move= true
	player.set_weapon()
	$POP_UP.hide()


func _on_seeker_pressed():
	PlayerStats.player_stat.attack_type = Player_Stats_Res.Attack_Type.SEEKER
	player.can_move= true
	player.set_weapon()
	$POP_UP.hide()


func _on_magic_pressed():
	PlayerStats.player_stat.attack_type = Player_Stats_Res.Attack_Type.MAGIC
	player.can_move= true
	player.set_weapon()
	$POP_UP.hide()


func _on_skip_pressed():
	player.can_move= true
	$POP_UP.hide()


func _on_camp_f_ire_body_entered(body):
	PlayerStats.heal()
	$Camp_FIre.set_deferred("monitorable",false)
	$Camp_FIre.set_deferred("monitoring",false)
