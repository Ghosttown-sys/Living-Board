extends Node

@onready var dialogues = $Dialogues
@onready var interactions_blocker = $CanvasLayer/Interactions_Blocker

@onready var actions_arrow = $CanvasLayer/Actions_Arrow
@onready var draw_card_arrow = $CanvasLayer/Draw_Card_Arrow
@onready var play_card_arrow = $CanvasLayer/Play_Card_Arrow
@onready var move_arrow = $CanvasLayer/Move_Arrow

var skip_tutorial = true

func _ready():
	
	if skip_tutorial:
		restore_interactions
	Events.on_game_started.connect(run_start_game_tutorial)
	Events.on_dialogue_ended.connect(restore_interactions)
	Events.on_dialogue_next_line.connect(_on_tutorial_dialogue_new_line)
	var par = get_parent()
	par.move_child.call_deferred(self,par.get_child_count())

func _on_tutorial_dialogue_new_line():
	if DialogueMgr.current_line == 2:
		actions_arrow.show()
	if DialogueMgr.current_line == 3:
		actions_arrow.hide()
		draw_card_arrow.show()
	if DialogueMgr.current_line == 4:
		draw_card_arrow.hide()
		play_card_arrow.show()
	if DialogueMgr.current_line == 5:
		play_card_arrow.hide()
		move_arrow.show()
	if DialogueMgr.current_line == 6:
		move_arrow.hide()
		

func run_start_game_tutorial():
	if skip_tutorial:
		return
	await get_tree().create_timer(1).timeout
	DialogueMgr.start_dialogue(dialogues.lines)

func restore_interactions():
	interactions_blocker.mouse_filter =  Control.MOUSE_FILTER_IGNORE

func block_interactions():
	if skip_tutorial:
		return
	interactions_blocker.mouse_filter =  Control.MOUSE_FILTER_STOP
