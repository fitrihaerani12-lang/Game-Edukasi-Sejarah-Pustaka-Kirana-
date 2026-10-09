shader_type canvas_item;

uniform float time_speed = 2.0;
uniform float glow_intensity = 0.6;
uniform vec2 book_center = vec2(0.5, 0.65); // Posisi tengah buku di gambar
uniform vec2 book_size = vec2(0.35, 0.25); // Area efek elips

void fragment() {
    vec2 uv = UV;
    
    // Menghitung area buku (membentuk elips mask)
    vec2 diff = (uv - book_center) / book_size;
    float dist = length(diff);
    
    // Mask yang lembut di pinggiran
    float mask = 1.0 - smoothstep(0.0, 1.0, dist);
    
    // Efek "melayang" / distorsi sihir ringan
    uv.y += sin(TIME * time_speed) * 0.01 * mask; // Naik turun
    
    // Ambil warna gambar asli
    vec4 color = texture(TEXTURE, uv);
    
    // Efek Cahaya (Denyut Emas)
    float pulse = (sin(TIME * time_speed * 1.5) * 0.5 + 0.5) * glow_intensity * mask;
    
    // Tambahkan cahaya emas
    color.rgb += vec3(pulse * 1.0, pulse * 0.8, pulse * 0.4);
    
    COLOR = color;
}
