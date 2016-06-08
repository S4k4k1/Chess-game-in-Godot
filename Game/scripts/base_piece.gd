
extends Area2D

#Base logic booleans
var is_selected = false
var is_on_top = false
var mouse_click = false
var mouse_clicked = false
var already_moved = false
#Cell movement logic
var movable_cells = []
var parent_cell = null
var selected_cell = null

#Capture required variables
var opponent_pieces = []

#Nodes needed
onready var parent = get_node("..")
onready var board = get_node("/root/main_scene/board")
onready var controller = get_node("/root/main_scene")

func _ready():
	set_process(true)
####################################################

func _process(delta):
	mouse_click = Input.is_action_pressed("mouse")
	if mouse_click and not mouse_clicked:
		if is_on_top:
			select_piece()
		else:
			move_to()
	mouse_clicked = mouse_click
####################################################

#Verifies which piece is being clicked
func _on_base_piece_mouse_enter():
	is_on_top = true
	controller.who = parent
	print(controller.who.get_name())
func _on_base_piece_mouse_exit():
	is_on_top = false
###################################################

func select_piece():
	#Toggle between selected and unselected
	if is_selected == false and parent.is_in_group(str(controller.turn)):
		is_selected = true
		movable_cells.clear()
		parent.calc_cell(parent.which_piece)

	else:
		is_selected = false
		movable_cells.clear()
		opponent_pieces.clear()
		print("deselected")
####################################################

func move_to():
	selected_cell = board.world_to_map(get_viewport().get_mouse_pos())
	#Clear cells that belong to allies
	for piece in parent.get_parent().get_children():
		if piece.is_in_group(parent.get_groups()[0]):
			movable_cells.erase(board.world_to_map(piece.get_pos()))
	#Clear every cell that is not the board cells
	for cell in movable_cells:
		if board.get_cell(cell.x, cell.y) == -1:
			movable_cells.erase(cell)
	if not selected_cell == parent_cell:
		if selected_cell in movable_cells:

			#verifies if the cell is occupied, and set the right behaviour if it is
			if (board.world_to_map(controller.who.get_pos()) in movable_cells):
				print(controller.who.get_groups())
				print(parent.get_groups())
				if (controller.who.get_groups() != parent.get_groups()):
					controller.who.queue_free()
					
			parent.set_global_pos(board.map_to_world(selected_cell))

			#Cleaning to the next turn
			movable_cells.clear()
			is_selected = false
			controller.toggle_turn()
####################################################
func _on_base_piece_exit_tree():
	print("I " + str(parent.get_name()) + " was captured")