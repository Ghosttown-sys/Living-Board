extends Card_Effect

@export var direction = Directions.DIRECTION.RIGHT

func apply_effect(args : Array):
	if args.size() != 1:
		printerr("arguments missmatch")
		return;
	Board_Manipulator.rotate_room(args[0], direction)
