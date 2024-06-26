extends CanvasLayer

signal scene_transitioning(new_scene_path)

@onready var _fade_animation:AnimationPlayer = $fadeAnimation
@onready var loading_bar : ProgressBar = $Loading
@onready var scroll_background = $ScrollBackground
@onready var load_bar_size = $Loading/LoadBarSize
@onready var player = $Loading/Player
@onready var is_loading := false
@onready var dialogue = $Dialogue

@onready var story = $Story
@onready var page_1 = $Story/Page1
@onready var page_2 = $Story/Page2
@export var imagePanels1: Array[TextureRect]
@export var imagePanels2: Array[TextureRect]


var scene_load_status = 0
var _scene_path := ""
var progress = []
var progress_value : int
var previous_progress_value = 0

var loadbar_size_max = 0

var story_line = 0

func _ready():
	loadbar_size_max = load_bar_size.size.x

func _process(_delta):
	if !is_loading:
		return
	if Game_Manager.storyTelled:
		_load_scene()
	else:
		loading_bar.visible = false
	
	if !Game_Manager.storyTelled and story.visible:
		if Input.is_action_just_pressed("continue_dialogue") and !DialogueMgr.typing:
			update_story(story_line)

func transition_to(scene_path: String):
	_scene_path = scene_path
	
	if !Game_Manager.storyTelled:
		story_line = 0
		for imagePanel in imagePanels1:
			imagePanel.self_modulate = Color("#000000d6")
		for imagePanel in imagePanels2:
			imagePanel.self_modulate = Color("#000000d6")
		story.visible = true
		page_2.visible = false
		page_1.visible = true
		DialogueMgr.start_dialogue(dialogue.lines)
	else:
		page_1.visible = false
		page_2.visible = false
	
	_load()

func update_story(line):
	if line < 2:
		imagePanels1[line].self_modulate = Color(0,0,0,0)
	elif line == 2:
		page_1.visible = false
		page_2.visible = true
	elif line < 7:
		imagePanels2[line - imagePanels1.size()-1].self_modulate = Color(0,0,0,0)
	else:
		Game_Manager.storyTelled = true
		loading_bar.value = 0
		loading_bar.visible = true
	story_line += 1

func _load():
	is_loading = true
	_fade_animation.play("fadeOut")
	loading_bar.visible = true
	scroll_background.visible = true
	get_tree().paused = true
	ResourceLoader.load_threaded_request(_scene_path)
	
	
func _load_scene():
	scene_load_status = ResourceLoader.load_threaded_get_status(_scene_path, progress)
	
	if progress[0] < 1:
		var new_progress_value = floor(progress[0] * 100)
	

		if new_progress_value > previous_progress_value:
			progress_value = new_progress_value
			previous_progress_value = new_progress_value
		elif new_progress_value < previous_progress_value:
			progress_value = previous_progress_value
		else:
			progress_value = previous_progress_value
		
	else :
		progress_value += randi_range(0,1)
	

	loading_bar.value = progress_value
	load_bar_size.size.x = loadbar_size_max * (loading_bar.value/100)
	player.position.x = load_bar_size.size.x
	
	
	if scene_load_status == ResourceLoader.THREAD_LOAD_LOADED:
		if loading_bar.value >= 100:
			_loaded()


func _loaded():
	var results = ResourceLoader.load_threaded_get(_scene_path)
	scene_transitioning.emit(_scene_path)
	var results_err_check = get_tree().change_scene_to_packed(results)
	if results_err_check != OK:
		printerr("TransitionMgr: could not change to scene '%s'" % _scene_path)
		return
	_reset()
	_fade_animation.play("fadeIn")

func _reset():
	loading_bar.visible = false
	scroll_background.visible = false
	is_loading = false
	story.visible = false
	get_tree().paused = false
	scene_load_status = 0
	progress = []
	previous_progress_value = 0
	
