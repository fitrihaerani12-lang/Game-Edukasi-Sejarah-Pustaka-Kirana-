extends Control

# ==========================================
# REFERENSI NODE (Penghubung script ke komponen UI di Scene)
# ==========================================
@onready var background = $Background
@onready var character = $Character
@onready var dialog_panel = $DialogPanel
@onready var dialog_text = $DialogPanel/DialogText
@onready var typewriter_timer = $TypewriterTimer

var top_bar: HBoxContainer
var score_label: Label

# ==========================================
# DATA PERCAKAPAN (Array berisi baris teks cerita)
# ==========================================
var dialog_lines: Array = [
	"Halo! Aku Kirana. Maukah kamu membantuku menyusun kembali sejarah nusantara yang hilang?"
]

# ==========================================
# VARIABEL STATE (Menyimpan status mesin ket ik saat ini)
# ==========================================
var current_line: int = 0         
var current_text: String = ""     
var text_index: int = 0           
var is_typing: bool = false       

# ==========================================
# FUNGSI UTAMA 
# ==========================================
func _ready() -> void:
	dialog_text.text = ""
	typewriter_timer.timeout.connect(_on_typewriter_timer_timeout)
	
	_beautify_ui()
	_setup_visuals()
	_play_bgm("bgm_library")
	
	# Mulai langsung tanpa animasi tambahan
	_start_dialog()

func _play_bgm(_base_name: String) -> void:
	GameManager.play_bgm("mainmenu_peta")

func _play_sfx(filename: String) -> void:
	GameManager.play_sfx(filename)


# ==========================================
# FUNGSI VISUAL & ESTETIKA UI
# ==========================================
func _beautify_ui() -> void:
	var panel_style = StyleBoxFlat.new()             
	panel_style.bg_color = Color(0, 0, 0, 0.6) 
	
	dialog_panel.add_theme_stylebox_override("panel", panel_style)
	dialog_text.add_theme_color_override("default_color", Color(1.0, 1.0, 1.0))
	
	# Muat Font Baru
	var custom_font = load("res://assets/images/fonts/CrimsonText-Bold.ttf")
	if custom_font:
		dialog_text.add_theme_font_override("normal_font", custom_font)
		dialog_text.add_theme_font_size_override("normal_font_size", 28)

func _setup_visuals() -> void:
	if ResourceLoader.exists("res://assets/images/bg_library.png"):
		background.texture = load("res://assets/images/bg_library.png")
	elif ResourceLoader.exists("res://assets/images/bg_library.jpg"):
		background.texture = load("res://assets/images/bg_library.jpg")
		
	var bg_shader = load("res://shaders/magic_book.gdshader") 
	if bg_shader:                                             
		var bg_mat = ShaderMaterial.new()                     
		bg_mat.shader = bg_shader                             
		background.material = bg_mat                          
		
	# -- PENGATURAN KARAKTER --
	# Karakter Kirana kini menggunakan komponen mandiri (char_kirana.tscn)
	# yang sudah menangani shader dan ekspresi secara otomatis.
	if character.has_method("appear"):
		character.appear()


# ==========================================
# LOGIKA MESIN KETIK & INTERAKSI PEMAIN
# ==========================================
func _start_dialog() -> void:
	current_text = ""               
	text_index = 0                  
	is_typing = true                
	dialog_text.text = ""           
	typewriter_timer.start()        

func _on_typewriter_timer_timeout() -> void:
	var full_string = dialog_lines[current_line]     
	
	if text_index < full_string.length():
		current_text += full_string[text_index]      
		dialog_text.text = current_text              
		text_index += 1                              
	else:
		is_typing = false                            
		typewriter_timer.stop()                      
		_check_dialog_end()                          

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_play_sfx("click_button.wav")
		if is_typing:
			is_typing = false                        
			typewriter_timer.stop()                  
			dialog_text.text = dialog_lines[current_line] 
			_check_dialog_end()                      
		else:
			if current_line < dialog_lines.size() - 1:
				current_line += 1                    
				_start_dialog()                      
			else:
				get_tree().change_scene_to_file("res://scenes/MapScene.tscn")

func _check_dialog_end() -> void:
	pass
