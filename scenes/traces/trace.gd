extends Area2D
class_name Trace

@export var explosion_scene: PackedScene = preload("res://scenes/effects/explosion.tscn")

# Stats
var health: float = 5.0
var damage: float = 5.0 # Matching your "1 trace = 10 value" logic
var speed: float = 180.0
var team_id: int = 0

# Movement variables
var target_node: Node2D = null
var orbit_angle: float = randf() * TAU 
var orbit_radius: float = randf_range(80.0, 115.0)

# State Machine
enum State { ORBIT, TRAVEL, DEFEND }
var current_state = State.ORBIT
var defender_target: Trace = null 

# Optimization
var logic_timer: float = 0.0
var logic_tick_rate: float = 0.2 
@export var guard_radius: float = 350.0 
@export var shield_responsiveness: float = 2.0 

func _ready():
	add_to_group("traces")

func _physics_process(delta):
	match current_state:
		State.ORBIT:
			_handle_logic_tick(delta)
			_handle_orbit(delta)
		State.TRAVEL:
			_handle_travel(delta)
		State.DEFEND:
			_handle_defense(delta)

# --- STATE HANDLERS ---

func _handle_orbit(delta):
	orbit_angle += delta * 2.0 
	var offset = Vector2(cos(orbit_angle), sin(orbit_angle)) * orbit_radius
	
	if get_parent():
		global_position = get_parent().global_position + offset
		
		# ROTATION FIX: 
		# Position Angle + 90 (Tangent/Velocity) + 90 (Sprite Offset) = 180 (PI)
		rotation = orbit_angle + PI

func _handle_travel(delta):
	if is_instance_valid(target_node):
		var direction = global_position.direction_to(target_node.global_position)
		global_position += direction * speed * delta
		
		# Align "Up" sprite to "Right" movement
		rotation = direction.angle() + PI/2
	else:
		current_state = State.ORBIT

func _handle_defense(delta):
	# Verify target and parent still exist, and the enemy is still targeting our parent
	if is_instance_valid(defender_target) and get_parent() and defender_target.target_node == get_parent():
		var parent_pos = get_parent().global_position
		
		# 1. Calculate the ideal angle to block the enemy
		var target_angle = parent_pos.angle_to_point(defender_target.global_position)
		
		# 2. Add individual spread so they form an ARC shield
		var individual_offset = (get_instance_id() % 11 - 5) * 0.15 
		var final_angle = target_angle + individual_offset
		
		# 3. Slide smoothly into position
		orbit_angle = lerp_angle(orbit_angle, final_angle, delta * shield_responsiveness)
		
		# 4. Update Position
		var offset = Vector2(cos(orbit_angle), sin(orbit_angle)) * orbit_radius
		global_position = parent_pos + offset
		
		# 5. Face the enemy being blocked
		# Add PI/2 because the sprite points UP, but Godot 0 degrees is RIGHT
		var face_dir = global_position.direction_to(defender_target.global_position)
		rotation = face_dir.angle() + PI/2
		
		# 6. Intercept/Damage Logic
		if global_position.distance_to(defender_target.global_position) < 25:
			defender_target.take_damage(self.damage)
			self.take_damage(defender_target.damage)
	else:
		# If the enemy dies or changes target, return to idle orbit
		current_state = State.ORBIT

# --- LOGIC & AI ---

func _handle_logic_tick(delta):
	logic_timer += delta
	if logic_timer >= logic_tick_rate:
		logic_timer = 0.0
		_check_for_intruders()

func _check_for_intruders():
	if current_state != State.ORBIT or not get_parent():
		return

	var traces = get_tree().get_nodes_in_group("traces")
	for intruder in traces:
		if is_instance_valid(intruder) and intruder.team_id != self.team_id:
			if intruder.target_node == get_parent():
				var dist_to_node = get_parent().global_position.distance_to(intruder.global_position)
				if dist_to_node < guard_radius:
					defender_target = intruder
					current_state = State.DEFEND
					break

# --- SIGNALS & COLLISION (UPDATED) ---

func set_target(new_target: Node2D):
	target_node = new_target
	current_state = State.TRAVEL

func _on_body_entered(body):
	# Verify we hit a Node we were aiming for
	if body.is_in_group("nodes") and body == target_node:
		
		# 1. ENEMY NODE: Always Attack
		if body.team_id != self.team_id:
			body.take_capture_damage(self.team_id, self.damage)
			spawn_explosion() # <--- BOOM
			queue_free()
			
		# 2. FRIENDLY NODE: Check if it needs "Feeding"
		else:
			# If node is NOT at max capacity (Level 3 full), we feed it
			if body.capture_value < body.LEVEL_3_CAP:
				body.take_capture_damage(self.team_id, self.damage)
				spawn_explosion() # <--- BOOM
				queue_free()
			else:
				# If full, just orbit normally
				_on_arrival(body)

func _on_area_entered(area):
	if (area is Trace and area.team_id != self.team_id):
		area.take_damage(self.damage)
		self.take_damage(area.damage)

func _on_arrival(new_node: Node2D):
	target_node = null
	current_state = State.ORBIT
	modulate = GameManager.get_team_trace_color(self.team_id)
	reparent.call_deferred(new_node)

func take_damage(amount: float):
	health -= amount
	if health <= 0:
		spawn_explosion() # <--- BOOM
		queue_free()

func _on_timer_timeout():
	visible = true

func spawn_explosion():
	if explosion_scene:
		var effect = explosion_scene.instantiate()
		
		# Critical: Add to the main scene, NOT the parent Node
		get_tree().current_scene.add_child(effect)
		
		effect.global_position = global_position
		effect.rotation = rotation # Match the trace's rotation for the initial burst alignment
		effect.modulate = GameManager.get_team_trace_color(team_id) * 1.5 # Make it glow brighter
		effect.emitting = true
