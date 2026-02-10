extends StaticBody2D

@export var trace_scene: PackedScene = preload("res://scenes/traces/trace.tscn")
@export var spawn_rate: float = 1.0
@export var team_id: int = 0 # 0 for Neutral, 1 for Player, etc.

@onready var spawn_timer = $Timer

@onready var progress_bar = $TextureProgressBar
var capture_value: float = 100.0 # 0 to 100
var max_capture: float = 100.0
var node_level = 0
var max_node_level = 3

func _ready():
	# Add to a group so Traces can identify it as a valid target
	add_to_group("nodes")
	
	if(team_id == 0):
		capture_value = 0
	else:
		node_level = 1
	
	# Initial visual setup 
	_update_visuals()
	
	# Setup Progress Bar
	progress_bar.max_value = max_capture
	progress_bar.value = 0
	progress_bar.visible = false
	
	spawn_timer.wait_time = spawn_rate
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	spawn_timer.start()

func _on_spawn_timer_timeout():
	# Neutral nodes (ID 0) should not spawn units
	if team_id != 0:
		spawn_trace()

func spawn_trace():
	for i in node_level:
		var new_trace = trace_scene.instantiate()
	
		# Important: Add as child so it inherits the orbit center
		add_child(new_trace)
	
		# Set the Trace to match the team's trace-specific intensity 
		new_trace.modulate = GameManager.get_team_trace_color(team_id)
		new_trace.team_id = team_id # Tell the trace what team it is on
	
		# Set initial position with offset
		new_trace.global_position = global_position + _get_random_offset()

func take_capture_damage(incoming_team_id: int, amount: float):
	# Show the bar when action starts
	progress_bar.visible = true
	
	if incoming_team_id == team_id:
		# Reinforce the node
		capture_value = min(capture_value + amount, max_capture)
		# Upgrade the node
		if(capture_value >= 100 && node_level < max_node_level):
			node_level += 1
			capture_value = 0.0
	elif(team_id == 0):
		capture_value = min(capture_value + amount, max_capture)
		if capture_value >= 100:
			change_team(incoming_team_id)
	else:
		# Enemy trace hitting the node
		capture_value -= amount
		if capture_value <= 0:
			if(node_level > 0):
				node_level -= 1
				capture_value = 100.0
			else:
				change_team(0)
			
	_update_progress_bar(incoming_team_id)

func _update_progress_bar(incoming_id: int):
	# Set the bar color to the team trying to take it
	progress_bar.tint_progress = GameManager.get_team_trace_color(incoming_id)
	# Use absolute value so the bar fills up even if capture_value is negative
	progress_bar.value = abs(capture_value)
	
	# Hide if fully captured/reinforced
	if progress_bar.value >= max_capture or progress_bar.value <= 0:
		progress_bar.visible = false

func change_team(new_id: int):
	team_id = new_id
	capture_value = 0.0 # Start with minimal influence
	_update_visuals()

func _update_visuals():
	# Applies the high-intensity glow color to the Node 
	modulate = GameManager.get_team_color(team_id)

func _get_random_offset() -> Vector2:
	return Vector2(randf_range(-20.0, 20.0), randf_range(-20.0, 20.0))
