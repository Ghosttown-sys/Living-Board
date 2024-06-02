class_name Monster_Data
extends Resource


enum MONSTER_TYPE {
	RANGED,
	MELEE
}

@export_category("Details")
@export var name : String
@export var sprite_frame_1 : AtlasTexture
@export var sprite_frame_2 : AtlasTexture
@export var monster_type : MONSTER_TYPE = MONSTER_TYPE.MELEE

@export_category("Stats")
@export var max_hp := 10.0
@export var damage := 2
@export var speed := 800.0
@export var rush_speed := 16000.0
@export var cd := 1.5
@export var cdm := 3.0
