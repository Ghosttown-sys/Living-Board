
extends Node2D

# The starting range of possible offsets using random values
@export var RANDOM_SHAKE_STRENGTH: float = 30.0
# Multiplier for lerping the shake strength to zero
@export var SHAKE_DECAY_RATE: float = 3.0


@onready var camera = $"../Camera"
# Used to keep track of where we are in the noise
# so that we can smoothly move through it
var noise_i: float = 0.0
@onready var rand = RandomNumberGenerator.new()
var shake_strength: float = 0.0

func apply_random_shake() -> void:
	shake_strength = RANDOM_SHAKE_STRENGTH
	
func _process(delta: float) -> void:
	# Fade out the intensity over time
	shake_strength = lerp(shake_strength, 0.0, SHAKE_DECAY_RATE * delta)
	
	var shake_offset: Vector2
	
	shake_offset = get_random_offset()
		
	# Shake by adjusting camera.offset so we can move the camera around the level via it's position
	camera.offset += shake_offset

func get_random_offset() -> Vector2:
	return Vector2(
		rand.randf_range(-shake_strength, shake_strength),
		rand.randf_range(-shake_strength, shake_strength)
	)
