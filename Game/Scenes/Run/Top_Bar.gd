extends CanvasLayer


func _on_pause_button_pressed():
	Events.pause_menu_requested.emit("pause")
