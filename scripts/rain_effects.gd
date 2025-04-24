class_name RainEffects extends CanvasLayer

var rain_count: int:
	get:
		var material := $ColorRect.material as ShaderMaterial
		return material.get_shader_parameter("count")
	set(count):
		var material := $ColorRect.material as ShaderMaterial
		material.set_shader_parameter("count", count)
