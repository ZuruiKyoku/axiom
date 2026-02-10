extends Node2D

var selected_node: StaticBody2D = null
var is_dragging: bool = false

# For the visual "Blueprint Line"
@onready var line_2d: Line2D = Line2D.new()

func _ready():
	add_child(line_2d)
	# Setup the line to look like a schematic vector
	line_2d.width = 5.0
	line_2d.default_color = GameManager.get_team_color(1)
	line_2d.z_index = 5 # Make sure it's above the nodes

func _input(event):
	# Handle both Mouse and Android Touch
	if event is InputEventMouseButton or event is InputEventScreenTouch:
		if event.pressed:
			_check_for_node_selection()
		elif is_dragging:
			_finalize_command()

	if event is InputEventMouseMotion and is_dragging:
		# Convert mouse world position to line-local position
		var local_mouse = line_2d.to_local(get_global_mouse_position())
		line_2d.set_point_position(1, local_mouse)

func _check_for_node_selection():
	var mouse_pos = get_global_mouse_position()
	for node in get_tree().get_nodes_in_group("nodes"):
		if node.global_position.distance_to(mouse_pos) < 50:
			if node.team_id == 1:
				selected_node = node
				is_dragging = true
				
				# Convert world position to line-local position
				var local_start = line_2d.to_local(selected_node.global_position)
				line_2d.add_point(local_start)
				line_2d.add_point(local_start)

func _update_vector_line(pos: Vector2):
	line_2d.set_point_position(1, get_global_mouse_position())

func _finalize_command():
	is_dragging = false
	var mouse_pos = get_global_mouse_position()
	var target_node = null
	
	for node in get_tree().get_nodes_in_group("nodes"):
		if node.global_position.distance_to(mouse_pos) < 50:
			if node != selected_node:
				target_node = node
				break
	
	if target_node:
		_send_units_to_target(target_node)
	
	line_2d.clear_points()
	selected_node = null

func _send_units_to_target(target):
	# Loop through all Traces orbiting the selected node
	for child in selected_node.get_children():
		if child.has_method("set_target"):
			child.set_target(target)
