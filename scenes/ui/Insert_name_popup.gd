extends Panel

@onready var button = $Button
@onready var input_field = $Name
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	button.disabled = input_field.text == ""

func _ready():
	input_field.text_changed.connect(_on_text_change)
	
func _on_text_change(text):
	Game_Manager.player_name = input_field.text
