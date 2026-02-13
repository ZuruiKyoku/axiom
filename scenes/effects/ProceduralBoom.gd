extends AudioStreamPlayer2D
class_name ProceduralSound

# STATIC VARIABLE: Shared by all instances of this script
static var cached_boom: AudioStreamWAV = null

func _ready():
	# 1. If we haven't generated the sound yet, do it now (ONCE)
	if cached_boom == null:
		_generate_sound_data()
	
	# 2. Assign the pre-calculated sound
	self.stream = cached_boom
	
	# 3. Randomize pitch (this is cheap)
	pitch_scale = randf_range(0.8, 1.2)
	
	# Note: Play is triggered by the parent Explosion.gd, 
	# or you can auto-play here if you prefer.

func _generate_sound_data():
	var sample_rate = 44100
	var duration = 0.4
	var frame_count = int(sample_rate * duration)
	
	var new_stream = AudioStreamWAV.new()
	new_stream.format = AudioStreamWAV.FORMAT_16_BITS
	new_stream.stereo = false
	
	var buffer = PackedByteArray()
	buffer.resize(frame_count * 2)
	
	var phase = 0.0
	var start_freq = 150.0
	
	for i in range(frame_count):
		var t = float(i) / frame_count
		var noise = randf_range(-1.0, 1.0)
		var current_freq = lerp(start_freq, 0.0, t * 2.0)
		phase += current_freq / sample_rate * TAU
		var sine = sin(phase)
		
		var raw_sample = (noise * 0.6) + (sine * 0.4)
		var envelope = exp(-8.0 * t) 
		var final_sample = raw_sample * envelope
		
		var sample_int = int(clamp(final_sample, -1.0, 1.0) * 32767)
		buffer.encode_s16(i * 2, sample_int)
	
	new_stream.data = buffer
	
	# Save to the static variable
	cached_boom = new_stream
