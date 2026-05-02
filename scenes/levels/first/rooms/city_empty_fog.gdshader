shader_type canvas_item;

uniform float speed : hint_range(0.1, 2.0) = 0.5;
uniform float density : hint_range(0.1, 1.0) = 0.6;

void fragment() {
    vec2 uv = UV + TIME * speed * 0.05;
    float noise = sin(uv.x * 8.0 + TIME) * cos(uv.y * 6.0 + TIME * 0.7) * 0.5 + 0.5;
    float noise2 = sin(uv.x * 4.0 - TIME * 0.5) * cos(uv.y * 9.0 + TIME) * 0.5 + 0.5;
    float fog = (noise + noise2) * 0.5 * density;
    COLOR.a = fog * COLOR.a;
}
