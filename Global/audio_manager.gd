extends Node

@onready var wall_move_sfx = $SFX/Wall_Move
@onready var game_start_sfx = $SFX/Game_Start
@onready var footstepo_sfx = $SFX/Foot_Steps


@onready var menu_music = $Music/Menu_Music
@onready var bg_music = $Music/Bg_Music
@onready var combat_music = $Music/Combat_Music

@onready var tracks = [menu_music,bg_music,combat_music]
"""
Tracklist:
	0 - menu_music
	1 - bg_music
	2 - combat_music
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
	tween.tween_property(tracks[track_to_play], "volume_db", 0, 1)
	await tween.tween_property(tracks[current_track], "volume_db", -80, 1)
	tracks[current_track].stop()
	current_track = track_to_play
	
