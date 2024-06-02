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
		light.color = normal_color if not hosting_monsters else monster_color
		
# rotation/ facing towards
var direction : Directions.DIRECTION = Directions.DIRECTION.UP
# which directions have a corridor
var openings : Array[Directions.DIRECTION]
# which other rooms this is connected to
var connections = {}
# coordinates in the grid
var coordinates : Vector2i;
@onready var light : Light2D = $light
@onready var tilemap : TileMap = $Room_Tilemap
@onready var targeted = $Targeted
@onready var monster_token_1 = $Monster_Token_1
@onready var monster_token_2 = $Monster_Token_2
@onready var monster_token_3 = $Monster_Token_3

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

var room_decors_database = preload("res://Game/Scenes/RoomsDecors/room_decors_databse.tres")

enum ROOM_TYPE {
	Normal = 15,
	Hazard = 45,
	Combat = 85,
	Treasure = 100
}

var room_type : ROOM_TYPE
@export var possible_monsters : Array[Monster_Data]
@export var hosting_monsters : Array[Monster_Data]

@export var normal_color : Color
@export var monster_color : Color

var hovering : bool:
	set(value):
		if value:
			targeted.show();
		else:
			targeted.hide();

func _ready():
	assign_random_openings()
	assign_random_room_type()
	assign_random_decorations()
	update_visuals()

func get_rotated_openings():
	var rotated_openings = []
	for opening in openings:
		# Remap direction considering room rotation
		var rotated_direction = (Directions.layer_index[opening]+ Directions.layer_index[direction]) % 4
		if rotated_direction < 0:
			rotated_direction += 4
		rotated_openings.append(Directions.direction_index[rotated_direction])
	return rotated_openings

func update_visuals():
	# for layers 1 to 4 (corridor layers)
	for layer in range(1,5):
		var direction = Directions.direction_index[layer - 1]
		tilemap.set_layer_enabled(layer, openings.has(direction));
	debug_label.text = str(room_type);

func get_room_pixel_size():
	return tilemap.get_used_rect().size * tilemap.rendering_quadrant_size
	
# At start, assign random openings to the room
func assign_random_openings():
	var directions : Array[Directions.DIRECTION] = Directions.ALL_DIRECTIONS.duplicate()
	for i in range(Game_Manager.RNG.randi() % directions.size()):
		var index = Game_Manager.RNG.randi() % directions.size()
		directions.remove_at(index)
	
	openings = directions;
	
func assign_random_room_type():
	var random_room_type = ROOM_TYPE.Normal
	var random_int = Game_Manager.RNG.randi_range(0,100)
	
	if random_int > 0 and random_int < ROOM_TYPE.Normal:
		random_room_type = ROOM_TYPE.Normal
	elif  random_int > ROOM_TYPE.Normal and random_int < ROOM_TYPE.Hazard:
		random_room_type = ROOM_TYPE.Hazard
	elif  random_int > ROOM_TYPE.Hazard and random_int < ROOM_TYPE.Combat:
		random_room_type = ROOM_TYPE.Combat
	elif  random_int > ROOM_TYPE.Combat and random_int < ROOM_TYPE.Treasure:
		random_room_type = ROOM_TYPE.Treasure
	
	room_type = random_room_type
	
func assign_random_decorations():
	var collection = room_decors_database.get_decorations(room_type)
	var random_index = Game_Manager.RNG.randi_range(0, collection.size() - 1)
	var decor_instance = collection[random_index].instantiate()
	add_child(decor_instance)
	if room_type == ROOM_TYPE.Combat:
		set_up_combat_room()

func set_up_combat_room():
	
	monster_token_1.monster_data = possible_monsters.pick_random()
	monster_token_2.monster_data = possible_monsters.pick_random()
	monster_token_3.monster_data = possible_monsters.pick_random()
	
	monster_token_1.update()
	monster_token_2.update()
	monster_token_3.update()

	var difficulty := randi_range(1,3)
	if difficulty == 1:
		monster_token_1.show()
		hosting_monsters.append(monster_token_1.monster_data)
		
	elif difficulty == 2:
		monster_token_2.show()
		hosting_monsters.append(monster_token_2.monster_data)
		monster_token_3.show()
		hosting_monsters.append(monster_token_3.monster_data)
		
	elif difficulty == 3:
		monster_token_1.show()
		hosting_monsters.append(monster_token_1.monster_data)
		monster_token_2.show()
		hosting_monsters.append(monster_token_2.monster_data)
		monster_token_3.show()
		hosting_monsters.append(monster_token_3.monster_data)
		

# Renders or hide the fog between corridors
func enable_corridor_fog(direction : Directions.DIRECTION, enabled : bool):
	var layer_index_offset = Directions.layer_index[self.direction];
	var direction_index = Directions.layer_index[direction]
	
	var rotated_index = (direction_index-layer_index_offset) % 4
	if rotated_index < 0:
		rotated_index += 4
	
	var fog_layer = rotated_index + 5;
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
