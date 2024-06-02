extends Card_Effect

@export var direction = Directions.DIRECTION.LEFT

func apply_effect(args : Array):
	if args.size() != 1:
		printerr("arguments missmatch")
		return;
	Board_Manipulator.push_row(args[0].y, direction)
