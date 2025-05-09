class_name TutorialMission extends Mission

func _init() -> void:
	scene = preload("res://scenes/tutorial.tscn")

func _ready() -> void:
	super()
	
	var end_area := get_tree().current_scene.find_child("EndArea") as Area2D
	end_area.body_entered.connect(_on_end_area_body_entered)

func _on_end_area_body_entered(body: PhysicsBody2D) -> void:
	if body is Player:
		PersistentData.done_tutorial = true
		mission_finished.emit(true)
