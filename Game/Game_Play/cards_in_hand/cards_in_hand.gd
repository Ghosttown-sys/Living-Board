extends Control

const CARD = preload("res://Game/Core/Card/Core_Card.tscn")
@export_category("Curves")
@export var spread_curve: Curve
@export var height_curve: Curve
@export var rotation_curve: Curve

var current_card: Card_UI
var card_index: int = 0
var hand_ratio: float = 0.5
var destination: Vector2
var rot_angle: int = 15
const ANIMATION_DURATION: float = 0.2
var mouse_pos: float

var position_offset: Vector2;

func _ready():
	add_cards(5)
	rearrange_cards()

func _process(_delta):
	rearrange_cards()
	# Add an offset to keep the hand fixed in screenspace without using canvas layers
	position_offset = get_canvas_transform().affine_inverse() * Vector2.ZERO

func add_cards(card_amount: int) -> void:
	for child_index in range(card_amount):
		var card = CARD.instantiate()
		add_child(card)
		
		card.initialize_card_effect()

func calculate_position(card: Card_UI) -> Vector2:
	var bottom_offset = get_viewport_rect().size.y / 8  # Adjust this value as needed
	var y_position = get_viewport_rect().size.y - bottom_offset - card.get_rect().size.y

	return Vector2(
		get_viewport_rect().get_center().x - card.get_rect().size.x / 2,
		y_position
	)

func calculate_card_destination(card: Card_UI, ratio: float, width: float, height: float, new_position: Vector2 = Vector2.ZERO) -> Vector2:
	if new_position == Vector2.ZERO:
		position = calculate_position(card)
	mouse_pos = 0.0

	position.x += spread_curve.sample(ratio) * width
	position += height_curve.sample(ratio + mouse_pos) * Vector2.UP * height
	
	return position + position_offset

func calculate_rotation(ratio: float, base_rotation: int) -> float:
	return rotation_curve.sample(ratio) * deg_to_rad(base_rotation)

func rearrange_cards() -> void:
	for card in get_cards():
		if card.dragging: 
			continue
		current_card = card
		card_index = get_cards().find(card)

		if get_cards().size() > 1:
			hand_ratio = float(card_index) / float( get_cards().size() - 1)
		else:
			hand_ratio = 0.5
		
		var hand_params = calculate_hand_parameters(get_cards().size())
		destination = calculate_card_destination(card, hand_ratio, hand_params[0], hand_params[2])
		var new_rotation = calculate_rotation(hand_ratio, hand_params[1])

		card.animate_to_position(destination, ANIMATION_DURATION, new_rotation)

func calculate_hand_parameters(child_count: int) -> Vector3:
	if child_count == 2:
		return Vector3(40, 2, 10)
	elif child_count == 3:
		return Vector3(80, 8, 8)
	elif child_count <= 10:
		return Vector3(child_count * 24, 12, 20)
	else:
		# Handle other cases or provide default values
		return Vector3(350, 12, 60)

func _input(event):
	if event is InputEventMouseMotion:
		if Input.is_action_pressed("drag_camera"):
			hide()
		else:
			show()
	
func get_cards():
	var cards_in_hand = []
	var all_cards = get_tree().get_nodes_in_group("card_in_hand")
	for card in get_children():
		if all_cards.has(card) && not card.dragging:
			cards_in_hand.append(card)
	return cards_in_hand
