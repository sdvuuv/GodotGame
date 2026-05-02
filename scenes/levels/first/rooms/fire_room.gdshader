shader_type canvas_item;

uniform float speed : hint_range(0.1, 3.0) = 1.2;
uniform float intensity : hint_range(0.1, 1.0) = 0.8;

void fragment() {
    vec2 uv = UV + TIME * speed * 0.03;
    float noise = sin(uv.x * 10.0 + TIME * 1.5) * cos(uv.y * 8.0 + TIME) * 0.5 + 0.5;
    float noise2 = sin(uv.x * 6.0 - TIME) * cos(uv.y * 12.0 + TIME * 0.8) * 0.5 + 0.5;
    float fire = (noise + noise2) * 0.5 * intensity;
    
    vec3 fire_color = mix(vec3(0.9, 0.2, 0.0), vec3(1.0, 0.8, 0.0), UV.y);
    COLOR.rgb = fire_color;
    COLOR.a = fire * COLOR.a;
}