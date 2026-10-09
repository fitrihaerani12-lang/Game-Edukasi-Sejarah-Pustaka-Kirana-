shader_type canvas_item;

uniform vec4 glow_color : source_color = vec4(1.0, 0.9, 0.5, 1.0);
uniform float speed = 2.0;
uniform float intensity = 0.5;

void fragment() {
    float dist = distance(UV, vec2(0.5));
    float mask = smoothstep(0.5, 0.2, dist);
    float pulse = (sin(TIME * speed) * 0.5 + 0.5) * intensity;
    COLOR = vec4(glow_color.rgb, mask * pulse);
}
