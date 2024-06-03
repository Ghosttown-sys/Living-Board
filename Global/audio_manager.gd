extends Node

@onready var wall_move_sfx = $SFX/Wall_Move
@onready var game_start_sfx = $SFX/Game_Start
@onready var footstepo_sfx = $SFX/Foot_Steps
@onready var draw_card_sfx = $SFX/Draw_Card
@onready var pop_sfx = $SFX/Pop
@onready var button_press_sfx = $SFX/Button_Press
@onready var take_damage_sfx = $SFX/Take_Damage

@onready var menu_music = $Music/Menu_Music
@onready var bg_music = $Music/Bg_Music
@onready var combat_music = $Music/Combat_Music
@onready var death_music = $Music/Death_Music
@onready var victory_music = $Music/Victory_Music

@onready var tracks = [menu_music,bg_music,combat_music,death_music,victory_music]
"""
Tracklist:
	0 - menu_music
	1 - bg_music
	2 - combat_music
	3 - death_music
	4 - victory_music
"""
var current_track : int = -1

func play_music(track_to_play):
	
	if track_to_play >= tracks.size() || track_to_play < 0:
		printerr("Invalid track index")
		return
	if track_to_play == current_track:
		return
	tracks[track_to_play].play()
	var tween = get_tree().create_tween()
	tween.tween_property(tracks[track_to_play], "volume_db", -20, 1)
	await tween.tween_property(tracks[current_track], "volume_db", -80, 1)
	tracks[current_track].stop()
	current_track = track_to_play
	
