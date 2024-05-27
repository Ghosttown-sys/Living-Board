extends NinePatchRect

# Called when the node enters the scene tree for the first time.
func _ready():
	Events.on_hover_room_enter.connect(_on_mouse_hover_enter_room)
	Events.on_hover_room_enter.connect(_on_mouse_hover_exit_room)

func _on_mouse_hover_enter_room(room):
	visible = true
	size = room.get_room_pixel_size();
	
	position = room.position - size/2

func _on_mouse_hover_exit_room(room):
	pass
