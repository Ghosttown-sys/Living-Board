extends RayCast2D
@onready var parent : Player = get_parent()
@onready var label = $CanvasLayer/Label

func _input(event):
	if Input.is_action_just_pressed("interact"):
		interact()

func interact():
	if self.is_colliding():
		get_collider().player_interact()


func _physics_process(delta):
	rotation = parent.direction.angle()
	if is_colliding():
		label.visible = true
		label.text = get_collider().label_text
	else :
		label.visible = false

