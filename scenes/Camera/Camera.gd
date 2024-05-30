extends Camera2D

@export var zoom_scale := Vector2(0.1,0.1)
@export var zoom_invert := false
@export var min_zoom := 0.5
@export var max_zoom := 1.5
@export var limit_offset := 1
@export var move_relative_to_zoom := false
@export var camera_speed := 100
@export var is_dragging := false



func _ready():
	Game_Manager.camera_relocate.connect(relocate_camera)
	
func _unhandled_input(event) -> void:
	drag_handler(event)


func _process(_delta):
	keys_handler()

func drag_handler(event) -> void:
	if event is InputEventMouseMotion:
		if Input.is_action_pressed("drag_camera"):
			is_dragging = true
			if move_relative_to_zoom:
				position -= event.relative * (zoom * 0.8)
			else:
				position -= event.relative
			position = Vector2(
				clamp(
					position.x,
					limit_left+get_viewport_rect().size.x/2,
					limit_right-get_viewport_rect().size.x/2
				),
				clamp(
					position.y,
					limit_top+get_viewport_rect().size.y/2,
					limit_bottom-get_viewport_rect().size.y/2
				)
			)
		else :
			is_dragging = false

#Camera control with keys
func keys_handler() -> void:
	var direction = Vector2(
		Input.get_axis("to_left_camera", "to_right_camera"),
		Input.get_axis("to_top_camera", "to_down_camera")
	)
	if  direction == Vector2(0,0):
		return
	if move_relative_to_zoom:
		position += direction.normalized() * camera_speed * (zoom * 0.8)
	else:
		position += direction.normalized() * camera_speed
	position = Vector2(
		clamp(
			position.x,
			limit_left+get_viewport_rect().size.x/2,
			limit_right-get_viewport_rect().size.x/2
		),
		clamp(
			position.y,
			limit_top+get_viewport_rect().size.y/2,
			limit_bottom-get_viewport_rect().size.y/2
		)
	)

#Camera zoom logic
func zoom_handler(event):
	var plus = "zoom_in" if zoom_invert else "zoom_out"
	var minus = "zoom_out" if zoom_invert else "zoom_in"
	if event.is_action_pressed(plus) and (zoom.x < max_zoom):
		zoom += zoom_scale
	if event.is_action_pressed(minus) and (zoom.x >= min_zoom):
			zoom -= zoom_scale


func relocate_camera(new_pos : Vector2)->void:
	var old_pos = position
	var displacement = old_pos - new_pos
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", position - displacement, 0.8).set_trans(Tween.TRANS_QUAD)
	
