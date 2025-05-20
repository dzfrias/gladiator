extends Node

@export var music_tracks: Array[AudioStreamWAV]

func _ready() -> void:
	call_deferred("play_music")

func play_music():
	var random_num = randi_range(0, music_tracks.size() - 1)
	var music = music_tracks[random_num]
	AudioManager.play_music(music)
