extends Node2D

@onready var tile_map = $TileMap

@export var grid = []
@export var grid_width = 5
@export var grid_height = 5

@export_category("Debug")
@export var print_grid_button: bool:
	set(value):
		print_grid()

func _ready():
	for i in grid_width:
		grid.append([])
		for j in grid_height:
			grid[i].append(str(j,"-",i))
	
func print_grid():
	if grid.is_empty():
		return;
	push_column(0, Game_Manager.DIRECTION.DOWN)
	for column in grid.size():
		print(grid[column], "\n")

func push_row(row_index, direction : Game_Manager.DIRECTION):
	print(" Pushing row ", row_index, " to the ", Game_Manager.DIRECTION.keys()[direction])
	if row_index >= grid_height:
		printerr(row_index, " is out of bound")
		return
	if direction != Game_Manager.DIRECTION.LEFT && direction != Game_Manager.DIRECTION.RIGHT:
		printerr(Game_Manager.DIRECTION.keys()[direction], " is not supported")
		return

	var row = grid[row_index]
	if direction == Game_Manager.DIRECTION.RIGHT:
		var tail = row.pop_back();
		row.push_front(tail);
	else:# direction == DIRECTION.LEFT
		var head = row.pop_front();
		row.push_back(head);

func push_column(col_index, direction : Game_Manager.DIRECTION):
	print(" Pushing column ", col_index, " to the ", Game_Manager.DIRECTION.keys()[direction])
	if col_index >= grid_width:
		printerr(col_index, " is out of bound")
		return
	if direction != Game_Manager.DIRECTION.UP && direction != Game_Manager.DIRECTION.DOWN:
		printerr(Game_Manager.DIRECTION.keys()[direction], " is not supported")
		return
	
	if direction == Game_Manager.DIRECTION.DOWN:
		# Remove the last element of each row and insert it at the start of the next row
		var tail = grid[grid_height - 1][col_index]
		for row in range(grid_height - 1, 0, -1):
			grid[row][col_index] = grid[row - 1][col_index]
		grid[0][col_index] = tail
	else:  # direction == DIRECTION.UP
		# Remove the first element of each row and append it to the end of the previous row
		var head = grid[0][col_index]
		for row in range(grid_height - 1):
			grid[row][col_index] = grid[row + 1][col_index]
		grid[grid_height - 1][col_index] = head
