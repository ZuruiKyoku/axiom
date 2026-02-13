extends Node
class_name AIBrain

# --- CONFIGURATION ---
@export var ai_interval: float = 2.0
@export var aggression: float = 0.65 # Default percentage to send
@export var base_attack_threshold: int = 16 

# --- PERSONALITY TRAITS (0.0 to 1.0) ---
var altruism: float = 0.0   # Likelihood to heal allies
var tactician: float = 0.0  # Likelihood to reinforce the frontline
var greed: float = 0.0      # Likelihood to hoard for upgrades

# --- REFERENCES ---
var body: Node2D = null # The Node this brain controls
var ai_timer: Timer = null

func _ready():
	# 1. Attach to Body
	body = get_parent()
	if not body or not body.is_in_group("nodes"):
		push_warning("AIBrain must be a child of a Node!")
		queue_free()
		return

	# 2. Generate Personality
	_randomize_personality()
	
	# 3. Start Thinking Loop
	ai_timer = Timer.new()
	add_child(ai_timer)
	# Add noise to the timer so enemies don't think in perfect sync
	ai_timer.wait_time = ai_interval + randf_range(-0.5, 0.5)
	ai_timer.timeout.connect(_think)
	ai_timer.start()

func _randomize_personality():
	altruism = randf()
	tactician = randf()
	greed = randf()
	
	# Archetype Overrides (Optional flavor)
	if randf() < 0.2: # "The Berserker"
		greed = 0.1
		base_attack_threshold = 12
	elif randf() < 0.2: # "The Turtle"
		greed = 0.9
		base_attack_threshold = 24

func _think():
	# Stop if captured or invalid
	if not is_instance_valid(body) or body.team_id <= 1:
		queue_free() 
		return

	# 1. Count Orbiting Traces (Ammo)
	var my_traces: Array[Trace] = []
	for child in body.get_children():
		if child is Trace and child.current_state == Trace.State.ORBIT:
			my_traces.append(child)
	
	if my_traces.is_empty():
		return

	# --- PILLAR 1: SURVIVAL (Panic) ---
	if body.capture_value < 50.0:
		_perform_heal(my_traces, 10)
		return

	# --- PILLAR 2: TEAMWORK (Rescue) ---
	if randf() < altruism:
		var ally_in_need = _find_ally_in_need()
		if ally_in_need:
			_launch_attack(my_traces, ally_in_need, 0.5) # Send 50% help
			return

	# --- PILLAR 3: AMBITION (Upgrade) ---
	if body.node_level < body.max_node_level:
		var upgrade_cost = 20 # Cost to hit next level (approx)
		var buffer = 5
		
		# If Greedy, we save strictly. If not, we might upgrade casually.
		var savings_goal = upgrade_cost + buffer
		if greed > 0.5:
			# Strict Saver: If I don't have enough, I pass turn (Hoard)
			if my_traces.size() < savings_goal:
				return 
		
		# Execute Upgrade if we have the funds
		if my_traces.size() >= savings_goal:
			_perform_heal(my_traces, upgrade_cost)
			return

	# --- PILLAR 4: FORWARD DEFENSE ---
	# Only Tacticians do this (Supply Lines)
	if tactician > 0.5:
		var frontline = _find_frontline_ally()
		if frontline:
			_launch_attack(my_traces, frontline, 0.3) # Send 30% supply
			return

	# --- PILLAR 5: AGGRESSION (Attack) ---
	# Dynamic Threshold: If low level, save up. If max level, attack freely.
	var current_threshold = base_attack_threshold
	if body.node_level == 1:
		current_threshold = 30 # Stingy at Level 1
	
	if my_traces.size() >= current_threshold:
		var target = _find_nearest_hostile()
		if target:
			_launch_attack(my_traces, target, aggression)

# --- HELPERS ---

func _perform_heal(traces: Array, amount: int):
	var count = min(traces.size(), amount)
	for i in range(count):
		if is_instance_valid(traces[i]):
			traces[i].set_target(body)

func _launch_attack(traces: Array, target: Node2D, percentage: float):
	var count = int(traces.size() * percentage)
	for i in range(count):
		if is_instance_valid(traces[i]):
			traces[i].set_target(target)

func _find_nearest_hostile() -> Node2D:
	var nodes = get_tree().get_nodes_in_group("nodes")
	var nearest = null
	var min_dist = INF
	
	for node in nodes:
		# Target Player (1) or Neutral (0)
		if node.team_id != body.team_id: 
			var dist = body.global_position.distance_squared_to(node.global_position)
			if dist < min_dist:
				min_dist = dist
				nearest = node
	return nearest

func _find_ally_in_need() -> Node2D:
	var nodes = get_tree().get_nodes_in_group("nodes")
	for node in nodes:
		if node.team_id == body.team_id and node != body:
			if node.capture_value < 30.0: # Critical health
				return node
	return null

func _find_frontline_ally() -> Node2D:
	var my_enemy_dist = _get_dist_to_enemy(body)
	var best_ally = null
	var best_diff = 0.0
	
	var nodes = get_tree().get_nodes_in_group("nodes")
	for node in nodes:
		if node.team_id == body.team_id and node != body:
			var ally_enemy_dist = _get_dist_to_enemy(node)
			
			# Is Ally closer to enemy than me? (Difference > 200px)
			if ally_enemy_dist < (my_enemy_dist - 200.0):
				# Find the one closest to the front
				if (my_enemy_dist - ally_enemy_dist) > best_diff:
					best_diff = my_enemy_dist - ally_enemy_dist
					best_ally = node
	return best_ally

func _get_dist_to_enemy(origin: Node2D) -> float:
	var nearest_dist = INF
	var nodes = get_tree().get_nodes_in_group("nodes")
	for node in nodes:
		if node.team_id != body.team_id:
			var d = origin.global_position.distance_squared_to(node.global_position)
			if d < nearest_dist:
				nearest_dist = d
	return sqrt(nearest_dist)
