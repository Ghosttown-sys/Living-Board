extends Node

@onready var wall_move_sfx = $SFX/Wall_Move

@onready var bg_music = $Music/Bg_Music
@onready var combat_music = $Music/Combat_Music

@onready var tracks = [bg_music,combat_music]
"""
Tracklist:
	0 - bg_music
	1 - combat_music
"""
var current_track : int

func play_music(track_to_play):
	
	if track_to_play >= tracks.size() || track_to_play < 0:
		printerr("Invalid track index")
		return
	
	tracks[track_to_play].play()
	var tween = get_tree().create_tween()
	tween.tween_property(tracks[current_track], "volume_db", 0, 0.8)
	tween.tween_property(tracks[track_to_play], "volume_db", 1, 0.8)
	current_track = track_to_play
