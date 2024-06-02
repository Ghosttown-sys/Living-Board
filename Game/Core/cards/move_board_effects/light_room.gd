extends Card_Effect

func apply_effect(args : Array):
	if args.size() != 1:
		printerr("arguments missmatch")
		return;
	Board_Manipulator.light_room(args[0])
