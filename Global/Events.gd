extends Node

signal remove_me(card:Card_UI)

signal board_move_begin;

signal on_hover_room_enter(room:room)
signal on_hover_room_exit(room:room)

signal on_card_returned_to_hand(card : Card_UI)
