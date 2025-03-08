class_name AudioManager extends Node

static func play_sound(node: Node2D, stream: AudioStreamWAV):
	var audio_player = AudioStreamPlayer2D.new()
	node.add_child(audio_player)
	audio_player.stream = stream
	audio_player.play()
	await audio_player.finished
	audio_player.queue_free()
