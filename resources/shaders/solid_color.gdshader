shader_type canvas_item;

uniform vec4 color: source_color;

void fragment() {
	vec4 texture_color = texture(TEXTURE, UV);
	COLOR = vec4(mix(texture_color.rgb, color.rgb, color.a), texture_color.a);
}