shader_type canvas_item;

uniform float similarity : hint_range(0.0, 1.0) = 0.15; // Diturunkan agar wajah/baju putih tidak ikut menjadi transparan
uniform float smoothness : hint_range(0.0, 1.0) = 0.05; 


uniform vec4 key_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

// Parameter untuk Drop Shadow agar sprite terlihat 3D/menonjol
uniform vec4 shadow_color : source_color = vec4(0.0, 0.0, 0.0, 0.6);
uniform vec2 shadow_offset = vec2(12.0, 15.0); // Geser shadow ke kanan bawah

void fragment() {
    // 1. Ambil warna karakter utama
    vec4 tex_color = texture(TEXTURE, UV);
    float dist = length(tex_color.rgb - key_color.rgb);
    float alpha = smoothstep(similarity, similarity + smoothness, dist);
    vec4 main_color = vec4(tex_color.rgb, tex_color.a * alpha);
    
    // 2. Ambil warna untuk bayangan (menggunakan UV yang digeser)
    vec2 shadow_uv = UV - (shadow_offset * TEXTURE_PIXEL_SIZE);
    
    // Jika bayangan keluar dari batas gambar, hilangkan
    vec4 final_color = main_color;
    if (shadow_uv.x >= 0.0 && shadow_uv.x <= 1.0 && shadow_uv.y >= 0.0 && shadow_uv.y <= 1.0) {
        vec4 shadow_tex = texture(TEXTURE, shadow_uv);
        float shadow_dist = length(shadow_tex.rgb - key_color.rgb);
        float shadow_alpha = smoothstep(similarity, similarity + smoothness, shadow_dist) * shadow_tex.a;
        
        vec4 drop_shadow = vec4(shadow_color.rgb, shadow_color.a * shadow_alpha);
        
        // 3. Gabungkan bayangan di bawah, karakter di atas
        final_color = mix(drop_shadow, main_color, main_color.a);
    }
    
    COLOR = final_color;
}
