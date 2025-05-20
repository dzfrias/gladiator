extends Node

var music: AudioStreamPlayer

func play_sound(node: Node, stream: AudioStreamWAV, volume_db = 0):
	var audio_player = AudioStreamPlayer2D.new()
	node.get_tree().current_scene.add_child(audio_player)
	if node is Node2D:
		audio_player.global_position = node.global_position
	audio_player.stream = stream
	audio_player.volume_db = volume_db
	audio_player.play()
	await audio_player.finished
	audio_player.queue_free()

func play_ui_sound(scene, stream: AudioStreamWAV, volume_db = 0):
	var audio_player = AudioStreamPlayer.new()
	scene.add_child(audio_player)
	audio_player.stream = stream
	audio_player.play()
	audio_player.volume_db = volume_db
	await audio_player.finished
	audio_player.queue_free()

func play_music(stream: AudioStreamWAV, volume_db = 0) -> void:
	if music != null:
		music.stop()
		music.free()
	music = AudioStreamPlayer.new()
	music.bus = "Music"
	get_tree().root.add_child(music)
	music.stream = stream
	music.play()
	music.volume_db = volume_db
	music.finished.connect(on_music_finished)
	
func on_music_finished():
	music.play()
