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

func push_column(col_index, direction : Directions.DIRECTION):
	if col_index >= grid_height:
		printerr(col_index, " is out of bound")
		return
	if direction != Directions.DIRECTION.UP && direction != Directions.DIRECTION.DOWN:
		printerr(Directions.DIRECTION.keys()[direction], " is not supported")
		return

	var column = grid[col_index]
	if direction == Directions.DIRECTION.DOWN:
		var tail = column.pop_back();
		column.push_front(tail);
	else:# direction == DIRECTION.UP
		var head = column.pop_front();
		column.push_back(head);
		
	Events.board_moved.emit();

func push_row(row_index, direction : Directions.DIRECTION):
	if row_index >= grid_width:
		printerr(row_index, " is out of bound")
		return
	if direction != Directions.DIRECTION.LEFT && direction != Directions.DIRECTION.RIGHT:
		printerr(Directions.DIRECTION.keys()[direction], " is not supported")
		return
	
	if direction == Directions.DIRECTION.RIGHT:
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

func rotate_room(coordinates, direction : Directions.DIRECTION):
	var facing_dir = grid[coordinates.x][coordinates.y].direction
	var rotation_dir = true if direction == Directions.DIRECTION.RIGHT else false
	grid[coordinates.x][coordinates.y].direction = Directions.get_dir_after_rotation(facing_dir, rotation_dir)
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
