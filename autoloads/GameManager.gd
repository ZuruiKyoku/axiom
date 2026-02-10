extends Node

# The Color Array using the Axiom Schematic Palette
# Intensity (I) is baked into the Color values here
var team_colors: Array[Color] = [
	Color(0.5, 0.5, 0.5), # 0: Neutral (No Glow)
	Color(0.0, 2.0, 2.0), # 1: Player (Cyan)
	Color(3.0, 1.2, 0.0), # 2: Enemy 1 (Orange)
	Color(2.0, 0.0, 2.0), # 3: Enemy 2 (Magenta)
	Color(2.0, 2.0, 0.0), # 4: Enemy 3 (Yellow)
	Color(0.5, 2.0, 0.0), # 5: Enemy 4 (Green)
	Color(0.2, 0.5, 2.0), # 6: Enemy 5 (Cobalt)
	Color(2.0, 0.0, 0.4)  # 7: Enemy 6 (Crimson)
]

var team_trace_colors: Array[Color] = [
	Color(0.5, 0.5, 0.5), # 0: Neutral (No Glow)
	Color(0.0, 1.0, 1.0), # 1: Player (Cyan)
	Color(1.0, 1.2, 0.0), # 2: Enemy 1 (Orange)
	Color(1.0, 0.0, 1.0), # 3: Enemy 2 (Magenta)
	Color(1.0, 1.0, 0.0), # 4: Enemy 3 (Yellow)
	Color(0.5, 1.0, 0.0), # 5: Enemy 4 (Green)
	Color(0.2, 0.5, 1.0), # 6: Enemy 5 (Cobalt)
	Color(1.0, 0.0, 0.4)  # 7: Enemy 6 (Crimson)
]

# Function to return a color based on the ID
func get_team_color(player_id: int) -> Color:
	if player_id >= 0 and player_id < team_colors.size():
		return team_colors[player_id]
	return Color.WHITE # Fallback if ID is invalid
	
func get_team_trace_color(player_id: int) -> Color:
	if player_id >= 0 and player_id < team_trace_colors.size():
		return team_trace_colors[player_id]
	return Color.WHITE # Fallback if ID is invalid
