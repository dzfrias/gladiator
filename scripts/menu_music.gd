extends Control

func _ready() -> void:
	AudioManager.call_deferred("play_music", load("res://assets/Music/main_menu_music.wav"), 8)
