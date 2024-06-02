extends Resource
class_name Rooms_Decors_Database

@export var room_normal : Array[PackedScene]
@export var room_hazards : Array[PackedScene]
@export var room_treasures : Array[PackedScene]

func get_decorations(room_type : Room.ROOM_TYPE):
	match room_type:
		Room.ROOM_TYPE.Normal:
			return room_normal
		Room.ROOM_TYPE.Hazard:
			return room_hazards
		Room.ROOM_TYPE.Combat:
			return room_normal
		Room.ROOM_TYPE.Treasure:
			return room_treasures
