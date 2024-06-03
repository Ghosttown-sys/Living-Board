extends Control

@export var screen_pos: Vector2
@onready var hand = $"../Cards_in_hand"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position = get_canvas_transform().affine_inverse() * screen_pos
	pass


func _on_interact(event):
	if event.is_action("select_card") and event.is_pressed() and not event.is_echo():
		if Game_Manager.is_player_turn and PlayerStats.consume_action():
			hand.add_cards(1)
			Events.on_move_finished.emit()
			AudioManager.draw_card_sfx.play()
