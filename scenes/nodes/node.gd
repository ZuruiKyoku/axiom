extends StaticBody2D

@export var trace_scene: PackedScene = preload("res://scenes/traces/trace.tscn")
@export var spawn_rate: float = 1.0
@export var team_id: int = 0 # 0 for Neutral, 1 for Player, etc.

@onready var level_1_sprite = $Level1_Sprite
@onready var level_2_sprite = $Level2_Sprite
@onready var level_3_sprite = $Level3_Sprite

@onready var spawn_timer = $Timer
@onready var progress_bar = $TextureProgressBar

# --- SOLUTION 2: CONTINUOUS HEALTH POOL ---
var capture_value: float = 100.0 
const LEVEL_1_CAP: float = 100.0
const LEVEL_2_CAP: float = 200.0
const LEVEL_3_CAP: float = 300.0

var node_level = 1
var max_node_level = 3

var last_click_time: float = 0.0
const DOUBLE_TAP_WINDOW: float = 300.0 

# (AI VARIABLES REMOVED - Handled by AIBrain)

func _ready():
	add_to_group("nodes")
	_update_visuals()
	set_sprite_level()
	
	# Setup Progress Bar
	progress_bar.value = 0
	progress_bar.visible = false
	
	spawn_timer.wait_time = spawn_rate
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	spawn_timer.start()
	
	# SETUP AI
	if team_id > 1: 
		_attach_brain()

func _on_spawn_timer_timeout():
	if team_id != 0:
		spawn_trace()

func spawn_trace():
	for i in node_level:
		var new_trace = trace_scene.instantiate()
		add_child(new_trace)
		new_trace.modulate = GameManager.get_team_trace_color(team_id)
		new_trace.team_id = team_id 
		new_trace.global_position = global_position + _get_random_offset()

func take_capture_damage(incoming_team_id: int, amount: float):
	progress_bar.visible = true
	
	# 1. NEUTRAL LOGIC
	if team_id == 0:
		capture_value -= amount
		if capture_value <= 0.0:
			change_team(incoming_team_id)
			capture_value = 100.0 
	
	# 2. FRIENDLY LOGIC
	elif incoming_team_id == team_id:
		capture_value += amount
		if capture_value > LEVEL_3_CAP:
			capture_value = LEVEL_3_CAP
			
	# 3. ENEMY LOGIC
	else:
		capture_value -= amount
		if capture_value <= 0:
			# KILL ALL TRACES
			for child in get_children():
				if child is Trace:
					# Ensure you have the spawn_explosion method in Trace.gd
					if child.has_method("spawn_explosion"):
						child.spawn_explosion()
					child.queue_free()
			change_team(0) 
			capture_value = 0.0

	_check_level_status()
	_update_progress_bar(incoming_team_id)

func _check_level_status():
	var old_level = node_level
	
	if capture_value >= LEVEL_3_CAP:
		node_level = 3
	elif capture_value >= LEVEL_2_CAP:
		node_level = 2
	elif capture_value > 0:
		node_level = 1
	else:
		node_level = 0
		
	if node_level != old_level:
		set_sprite_level()

func _update_progress_bar(incoming_id: int):
	progress_bar.tint_progress = GameManager.get_team_trace_color(incoming_id)
	
	var display_value = fmod(capture_value, 100.0)
	if display_value == 0 and capture_value > 0:
		display_value = 100.0
		
	progress_bar.value = display_value
	
	if capture_value == LEVEL_1_CAP or capture_value == LEVEL_2_CAP or capture_value == LEVEL_3_CAP:
		progress_bar.visible = false
	elif capture_value <= 0:
		progress_bar.visible = false
	else:
		progress_bar.visible = true

func change_team(new_id: int):
	team_id = new_id
	
	# Handle Brain Logic
	_remove_brain() # Always remove old brain first
	if team_id > 1: 
		_attach_brain() # Add new brain if enemy
		
	_update_visuals()

func _attach_brain():
	# Dynamic script loading
	var brain_script = load("res://scenes/nodes/AIBrain.gd")
	if brain_script:
		var brain = brain_script.new()
		brain.name = "AIBrain"
		add_child(brain)

func _remove_brain():
	if has_node("AIBrain"):
		get_node("AIBrain").queue_free()

func _update_visuals():
	modulate = GameManager.get_team_color(team_id)
	
func set_sprite_level():
	level_1_sprite.visible = (node_level >= 1)
	level_2_sprite.visible = (node_level >= 2)
	level_3_sprite.visible = (node_level >= 3)

func _absorb_all_traces():
	for child in get_children():
		if child is Trace:
			child.set_target(self)

func _get_random_offset() -> Vector2:
	return Vector2(randf_range(-20.0, 20.0), randf_range(-20.0, 20.0))

func _on_input_event(viewport, event, shape_idx):
	if team_id == 1:
		# EXCLUSIVE: Only check Mouse Button.
		# On Android, the "Emulate Mouse From Touch" setting will turn 
		# your tap into this event automatically.
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			var current_time = Time.get_ticks_msec()
			
			# Check time difference for double tap
			if current_time - last_click_time < DOUBLE_TAP_WINDOW:
				_absorb_all_traces()
				
			last_click_time = current_time
