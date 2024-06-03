extends CanvasLayer

@onready var sanity_loss = $Sanity_loss
@onready var hp_loss = $Hp_loss
@onready var flash_timer = $Flash_Timer
@onready var hp_gained = $Hp_Gained


func _ready():
	Events.hp_lost.connect(_hp_lost)
	Events.sanity_lost.connect(_sanity_lost)
	Events.hp_gained.connect(_hp_ganined)

func _hp_lost():
	hp_loss.color.a = 0.3
	flash_timer.start()

func _sanity_lost():
	sanity_loss.color.a = 0.3
	flash_timer.start()

func _hp_ganined():
	hp_gained.color.a = 0.3
	flash_timer.start()


func _on_flash_timer_timeout():
	hp_loss.color.a = 0.0
	sanity_loss.color.a = 0.0
	hp_gained.color.a = 0.0
