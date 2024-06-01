extends Node2D
class_name Room


static var static_id : int

var is_hosting_player := false
var room_id : int : 
	set(value):
		room_id = value;
		static_id += 1
var active : bool :
	set(value):
		var tween = get_tree().create_tween()
		var target = 1 if value else 0
		tween.tween_property(light, "energy", target, 0.2).set_trans(Tween.TRANS_QUAD)
		
# rotation/ facing towards
var direction : Game_Manager.DIRECTION = Game_Manager.DIRECTION.UP
# which directions have a corridor
var openings : Array[Game_Manager.DIRECTION]
# which other rooms this is connected to
var connections = {}
# coordinates in the grid
var coordinates : Vector2i;
@onready var light : Light2D = $light
@onready var tilemap : TileMap = $Room_Tilemap
@onready var targeted = $Targeted
"""
Tilemap layers are:
	0 : Base
	
	1 : Left_Corridor
	2 : Right_Corridor
	3 : Top_Corridor
	4 : Bottom_Corridor
	
	5 : Left_Fog
	6 : Right_Fog
	7 : Top_Fog
	8 : Bottom_Fog
"""
@onready var debug_label = $Label

@onready var rng = RandomNumberGenerator.new()

var hovering : bool:
	set(value):
		if value:
			targeted.show();
		else:
			targeted.hide();

func _ready():
	assign_random_openings()
	update_visuals()

func update_visuals():
	# for layers 1 to 4 (corridor layers)
	for layer in range(0,4):
		var direction = Game_Manager.direction_index[layer]
		tilemap.set_layer_enabled(layer + 1, openings.has(direction));
	debug_label.text = str(room_id);

func get_room_pixel_size():
	return tilemap.get_used_rect().size * tilemap.rendering_quadrant_size
	
# At start, assign random openings to the room
func assign_random_openings():
	var directions : Array[Game_Manager.DIRECTION] = Game_Manager.ALL_DIRECTIONS.duplicate()
	for i in range(Game_Manager.RNG.randi() % directions.size()):
		var index = Game_Manager.RNG.randi() % directions.size()
		directions.remove_at(index)
	
	openings = directions;

# Renders or hide the fog between corridors
func enable_corridor_fog(direction : Game_Manager.DIRECTION, enabled : bool):
	var direction_index = Game_Manager.layer_index[direction]
	
	var fog_layer = direction_index + 5;
	tilemap.set_layer_enabled(fog_layer, enabled);
	
func _on_mouse_entered():
	var tween = get_tree().create_tween()
	tween.tween_property(self, "scale", Vector2(1.1,1.1), 0.2).set_trans(Tween.TRANS_BOUNCE)
	
func _on_mouse_exited():
	var tween = get_tree().create_tween()
	tween.tween_property(self, "scale", Vector2(1,1), 0.2).set_trans(Tween.TRANS_BOUNCE)
	
func _on_area_entered(area):
	if area is Player:
		return
	targeted.show()
	hovering = true
	Events.on_card_hovering_room_enter.emit(self)

func _on_area_exited(area):
	hovering = false
	Events.on_card_hovering_room_exit.emit(self)
