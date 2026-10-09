shader_type canvas_item;

uniform float speed = 1.0;
uniform float intensity = 0.5;

void fragment() {
    vec2 uv = UV;
    float time = TIME * speed;
    
    // Simple noise-like flicker
    float flicker = sin(time * 10.0) * 0.1 + sin(time * 25.0) * 0.05;
    
    vec4 color = texture(TEXTURE, uv);
    color.rgb *= (1.0 + flicker * intensity);
    
    // Pulse scale effect simulation in fragment (glow)
    float pulse = sin(time * 3.0) * 0.1 + 0.9;
    if (color.a > 0.0) {
        color.a *= pulse;
    }
    
    COLOR = color;
}
