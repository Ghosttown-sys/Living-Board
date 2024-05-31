extends Card_Effect

@export var direction = Game_Manager.DIRECTION.UP

func apply_effect(args : Array):
	if args.size() != 1:
		printerr("arguments missmatch")
		return;
	Board_Manipulator.push_column(args[0].x, direction)
