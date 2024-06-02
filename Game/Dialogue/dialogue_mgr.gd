extends CanvasLayer

@onready var dialogue_lines = $Panel/DialogueLines
@onready var panel = $Panel

var dialogue = []
var current_line = 0
var typing = false
var char_index = 0
var typing_speed = 0.02 # Adjust typing speed here

func _process(_delta):
	if Input.is_action_just_pressed("continue_dialogue"):
		if typing:
			dialogue_lines.text = dialogue[current_line - 1]
			char_index = len(dialogue[current_line - 1]) 
			typing = false
		else:
			next_line()

func start_dialogue(new_dialogue):
	panel.visible = true
	dialogue = new_dialogue
	current_line = 0
	next_line()

func next_line():
	if current_line < len(dialogue):
		type_write_effect(dialogue[current_line])
		current_line += 1
	else:
		end_dialogue()
	
	Events.on_dialogue_next_line.emit()

func end_dialogue():
	Events.on_dialogue_ended.emit()
	dialogue_lines.text = ""
	panel.visible = false

func type_write_effect(line):
	dialogue_lines.text = ""
	char_index = 0
	typing = true
	start_typing(line)

func start_typing(line):
	while char_index < len(line):
		dialogue_lines.text += line[char_index]
		char_index += 1
		await get_tree().create_timer(typing_speed).timeout
	typing = false
