class_name RainEffects extends Node

var rain_count: int:
	get:
		var material := $Rain/ColorRect.material as ShaderMaterial
		return material.get_shader_parameter("count")
	set(count):
		var material := $Rain/ColorRect.material as ShaderMaterial
		material.set_shader_parameter("count", count)

func set_bounds(left: float, right: float) -> void:
	$DropletScanner.set_bounds(left, right)
