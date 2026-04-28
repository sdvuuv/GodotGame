shader_type canvas_item;

uniform float intensity : hint_range(0.0, 1.0) = 0.0;
uniform vec3 color : source_color = vec3(0.0, 0.0, 0.0);

void fragment() {
	vec2 uv = UV - vec2(0.5);
	float dist = length(uv) * 2.0;
	float vignette = pow(dist, 2.5);
	COLOR = vec4(color, vignette * intensity);
}