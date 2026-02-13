extends CPUParticles2D

@onready var audio = $AudioStreamPlayer2D

func _ready():
	# Note: We do NOT set 'emitting = true' here. 
	# We let the spawner (Trace.gd) do that to ensure it's in the right position first.
	
	# 1. Play the procedural sound
	# (The child script generated the stream, now we play it)
	if audio.stream:
		audio.play()
	
	# 2. Cleanup Logic
	# Calculate how long to wait based on the generated sound
	var particle_time = lifetime + 0.1
	var audio_time = audio.stream.get_length() if audio.stream else 0.0
	
	# Wait for the longest one
	var wait_time = max(particle_time, audio_time)
	
	await get_tree().create_timer(wait_time).timeout
	queue_free()
