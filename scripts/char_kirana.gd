extends TextureRect

# Path folder karakter
const CHAR_PATH = "res://assets/images/chars/"

const EXPRESSIONS = {
	"NEUTRAL": "char_kirana.png",
	"SEMANGAT": "char_kirana.png", # Fallback since jpeg is missing
	"SENANG": "char_kirana.png", # Fallback since jpeg is missing
	"BERPIKIR": "char_kirana.png", # Fallback since jpeg is missing
	"EXCITED": "char_kirana_map_excited.png",
	"GUIDE": "char_kirana_map_guide.png",
	"KAGET": "char_kirana_kaget.png",
	"MATERI": "char_kirana_materi.png"
}

func set_expression(expr_name: String):
	var file_name = EXPRESSIONS.get(expr_name, "char_kirana.png")
	var full_path = CHAR_PATH + file_name
	
	if ResourceLoader.exists(full_path):
		texture = load(full_path)
		# If it's a transparent PNG asset, we clear the remove_white material to avoid visual defects
		if expr_name in ["EXCITED", "GUIDE", "KAGET", "MATERI"]:
			material = null
		else:
			# Restore white removal shader for original white-background texture
			var shader_res = load("res://shaders/remove_white.gdshader")
			if shader_res:
				var mat = ShaderMaterial.new()
				mat.shader = shader_res
				mat.set_shader_parameter("similarity", 0.18)
				mat.set_shader_parameter("smoothness", 0.03)
				mat.set_shader_parameter("key_color", Color(1, 1, 1, 1))
				material = mat
	else:
		push_error("Gagal memuat: " + full_path)

# Fungsi appear yang disesuaikan untuk Sprite2D
func appear():
	modulate.a = 0
	var tween = create_tween()
	# Animasi muncul dari transparan ke terlihat
	tween.tween_property(self, "modulate:a", 1.0, 0.5)
