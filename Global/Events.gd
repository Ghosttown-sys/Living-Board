extends Node

signal board_moved;

signal on_card_hovering_room_enter(room:Room)
signal on_card_hovering_room_exit(room:Room)

signal on_player_stats_changed

signal on_dialogue_next_line
signal on_dialogue_ended

signal on_game_started

signal on_move_finished

signal victory
signal player_died

signal hp_lost
signal sanity_lost
signal hp_gained

signal add_score(score:int)
