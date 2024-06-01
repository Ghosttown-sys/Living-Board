extends Node2D

var grid_height : int
var grid_width : int
var grid = [] : 
	set(value):
		grid = value
		grid_height = value.size()
		grid_width = value[0].size()

func print_grid():
	if grid.is_empty():
		return;
	var to_print = ""
	for column in grid[0].size():
		for row in grid.size():
			to_print += str(grid[row][column].room_id) + "-"
		to_print += "\n"
	print(to_print)

func push_column(col_index, direction : Game_Manager.DIRECTION):
	print(" Pushing column ", col_index, " to the ", Game_Manager.DIRECTION.keys()[direction])
	if col_index >= grid_height:
		printerr(col_index, " is out of bound")
		return
	if direction != Game_Manager.DIRECTION.UP && direction != Game_Manager.DIRECTION.DOWN:
		printerr(Game_Manager.DIRECTION.keys()[direction], " is not supported")
		return

	var column = grid[col_index]
	if direction == Game_Manager.DIRECTION.DOWN:
		var tail = column.pop_back();
		column.push_front(tail);
	else:# direction == DIRECTION.UP
		var head = column.pop_front();
		column.push_back(head);
		
	Events.board_moved.emit();

func push_row(row_index, direction : Game_Manager.DIRECTION):
	print(" Pushing row ", row_index, " to the ", Game_Manager.DIRECTION.keys()[direction])
	if row_index >= grid_width:
		printerr(row_index, " is out of bound")
		return
	if direction != Game_Manager.DIRECTION.LEFT && direction != Game_Manager.DIRECTION.RIGHT:
		printerr(Game_Manager.DIRECTION.keys()[direction], " is not supported")
		return
	
	if direction == Game_Manager.DIRECTION.RIGHT:
		# Remove the last element of each row and insert it at the start of the next row
		var tail = grid[grid_height - 1][row_index]
		for row in range(grid_height - 1, 0, -1):
			grid[row][row_index] = grid[row - 1][row_index]
		grid[0][row_index] = tail
	else:  # direction == DIRECTION.LEFT
		# Remove the first element of each row and append it to the end of the previous row
		var head = grid[0][row_index]
		for column in range(grid_height - 1):
			grid[column][row_index] = grid[column + 1][row_index]
		grid[grid_height - 1][row_index] = head
	
	Events.board_moved.emit();

func rotate_room(coordinates, direction : Game_Manager.DIRECTION):
	var facing_dir = grid[coordinates.x][coordinates.y].direction
	var rotation_dir = true if direction == Game_Manager.DIRECTION.RIGHT else false
	grid[coordinates.x][coordinates.y].direction = Game_Manager.get_dir_after_rotation(facing_dir, rotation_dir)
	Events.board_moved.emit();

func get_row(index):
	return grid[index]

func get_column(index):
	var column = []
	for row_index in grid_height:
		column.append(grid[row_index][index])
	return column

func get_all_columns() -> Array:
	var columns = []
	var num_columns = grid_width

	for col in range(num_columns):
		var column = []
		for row in range(grid.size()):
			column.append(grid[row][col])
		columns.append(column)
	return columns
