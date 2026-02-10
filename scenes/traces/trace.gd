extends Area2D

# Stats
var health: float = 10.0
var damage: float = 5.0
var speed: float = 180.0
var team_id: int = 0

# Movement variables
var target_node: Node2D = null
var orbit_angle: float = randf() * TAU 
var orbit_radius: float = randf_range(80.0, 115.0)

func _physics_process(delta):
	if target_node:
		# Only move toward target. Collision will handle the arrival/impact.
		var direction = global_position.direction_to(target_node.global_position)
		global_position += direction * speed * delta
	else:
		# IDLE ORBIT
		orbit_angle += delta * 2.0 
		var offset = Vector2(cos(orbit_angle), sin(orbit_angle)) * orbit_radius
		# Parent check to prevent errors during reparenting frames
		if get_parent():
			global_position = get_parent().global_position + offset

func _on_area_entered(area):
	if(area.team_id != team_id):
		area.take_damage(damage)
		take_damage(area.damage)

func _on_arrival(new_node):
	target_node = null
	# Ensure color stays as the TRACE version
	modulate = GameManager.get_team_trace_color(self.team_id)
	# Use Godot 4.6's built-in reparenting
	reparent.call_deferred(new_node)

func set_target(new_target):
	target_node = new_target

func take_damage(amount: float):
	health -= amount
	if health <= 0:
		queue_free()

func _on_timer_timeout():
	visible = true

func _on_body_entered(body):
	# 1. Verify it's a node and it's our specific destination
	if body.is_in_group("nodes") and body == target_node:
		
		# 2. COMBAT CHECK: Neutral (0) or Enemy (Not Player)
		if body.team_id != self.team_id:
			body.take_capture_damage(self.team_id, self.damage)
			queue_free() # Destroys the trace on impact
			return 
			
		# 3. ARRIVAL CHECK: Same team
		else:
			if(body.capture_value < body.max_capture || body.node_level < body.max_node_level):
				body.take_capture_damage(self.team_id, self.damage)
				queue_free() # Destroys the trace on impact
				return
			else:
				_on_arrival(body)
