class_name AudioManager extends Node

static func play_sound(node: Node2D, stream: AudioStreamWAV):
	var audio_player = AudioStreamPlayer2D.new()
	node.get_tree().current_scene.add_child(audio_player)
	audio_player.global_position = node.global_position
	audio_player.stream = stream
	audio_player.play()
	await audio_player.finished
	audio_player.queue_free()

static func play_ui_sound(scene, stream: AudioStreamWAV, volume_db = 0):
	var audio_player = AudioStreamPlayer.new()
	scene.add_child(audio_player)
	audio_player.stream = stream
	audio_player.play()
	audio_player.volume_db = volume_db
	await audio_player.finished
	audio_player.queue_free()
