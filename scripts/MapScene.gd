extends Control

@onready var kirana_character = $Kirana
@onready var dialog_container = $DialogContainer
@onready var dialog_text = $DialogContainer/DialogPanel/DialogText

# Glows
@onready var jogja_glow = $Glows/Jogja
@onready var sumatra_glow = $Glows/Sumatra
@onready var maluku_glow = $Glows/Maluku

var dialogues_intro = [
	"Perjalanan kita dimulai dari sebuah tempat yang penuh makna...",
	"Di Yogyakarta, benih-benih kebangkitan bangsa mulai tumbuh melalui pendidikan dan persatuan.",
	"Lihatlah... ada satu wilayah yang bersinar di peta.",
	"Sepertinya, di sanalah langkah pertama kita dimulai.",
	"Mari kita mulai dari wilayah yang bersinar itu."
]

var dialogues_jogja_done = [
	"Hebat! Kamu berhasil membuka bagian pertama dari perjalanan ini.",
	"Peta Nusantara mulai pulih, dan semakin banyak kisah yang bisa kita jelajahi.",
	"Sekarang, kita memiliki dua pilihan perjalanan berikutnya..."
]

var dialogues_choices = [
	"Ke Timur, untuk menelusuri jejak rempah dan perlawanan di Maluku...",
	"Atau ke Barat, untuk memahami strategi perjuangan di Sumatra Barat.",
	"Ke mana kita akan melangkah selanjutnya?"
]

var dialogues_sumatra_done = [
	"Perjalanan kita masih belum selesai...",
	"Sekarang, mari kita lanjutkan ke Maluku, daerah yang terkenal dengan kekayaan rempah-rempah dan semangat perjuangannya."
]

var dialogues_maluku_done = [
	"Hebat! Kita telah menyelesaikan seluruh perjalanan sejarah Nusantara.",
	"Setiap wilayah telah berhasil mengembalikan bagian pengetahuan yang hilang…",
	"Sekarang… seluruh kisah itu telah kembali ke tempat asalnya.",
	"Mari kita kembali ke Pustaka Kirana."
]

var current_dialogue_list = []
var current_dialogue_index = 0
var is_typing = false
var typing_speed = 0.05
var state = "INTRO" # INTRO, JOGJA_ACTIVE, POST_JOGJA, CHOICES, POST_SUMATRA, MALUKU_ACTIVE
var is_jogja_complete = false

func _ready():
	_setup_ui()
	_play_bgm("bgm_map")
	
	if GameManager.is_maluku_completed:
		_start_post_maluku()
	elif GameManager.is_sumatra_completed:
		_start_post_sumatra()
	elif GameManager.is_jogja_completed:
		jogja_glow.visible = true
		_start_post_jogja()
	else:
		_start_intro()

func _setup_ui():
	dialog_container.visible = true
	kirana_character.visible = true
	
	# Initial Kirana setup
	kirana_character.texture = load("res://assets/images/chars/char_kirana_map_guide.png")
	
	# Hide all region glows initially
	jogja_glow.visible = false
	sumatra_glow.visible = false
	maluku_glow.visible = false
	
	# Setup click signals for the glow nodes
	jogja_glow.gui_input.connect(_on_region_clicked.bind("Jogja"))
	sumatra_glow.gui_input.connect(_on_region_clicked.bind("Sumatra"))
	maluku_glow.gui_input.connect(_on_region_clicked.bind("Maluku"))

func _start_intro():
	state = "INTRO"
	current_dialogue_list = dialogues_intro
	current_dialogue_index = 0
	show_next_dialogue()

func _input(event):
	if event.is_action_pressed("ui_accept") or (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		# Play click SFX only when we are actively progressing dialogue!
		if is_typing or current_dialogue_index < current_dialogue_list.size():
			_play_sfx("click.wav")
			if is_typing:
				is_typing = false
				dialog_text.visible_characters = -1
			else:
				show_next_dialogue()
		elif state == "INTRO" and current_dialogue_index >= current_dialogue_list.size():
			state = "JOGJA_ACTIVE"
		elif state == "POST_SUMATRA" and current_dialogue_index >= current_dialogue_list.size():
			state = "MALUKU_ACTIVE"
		elif state == "POST_MALUKU" and current_dialogue_index >= current_dialogue_list.size():
			return # Force player to click the "Kembali" button

func show_next_dialogue():
	if current_dialogue_index >= current_dialogue_list.size():
		return
		
	is_typing = true
	dialog_text.text = current_dialogue_list[current_dialogue_index]
	dialog_text.visible_characters = 0
	
	# Typing effect
	while dialog_text.visible_characters < dialog_text.text.length():
		if not is_typing: break
		dialog_text.visible_characters += 1
		var tree = get_tree()
		if not tree: break
		await tree.create_timer(typing_speed).timeout
	
	is_typing = false
	current_dialogue_index += 1
	
	if state == "POST_MALUKU" and current_dialogue_index == dialogues_maluku_done.size():
		show_kembali_button()
	
	# Show Jogja glow when mentioned
	if state == "INTRO" and current_dialogue_index == 3:
		jogja_glow.visible = true
	
	if state == "POST_JOGJA" and current_dialogue_index >= current_dialogue_list.size():
		_start_choices()
	
	if state == "POST_SUMATRA" and current_dialogue_index >= current_dialogue_list.size():
		state = "MALUKU_ACTIVE"

func _on_region_clicked(event, region_name):
	if not (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		return
	_play_sfx("click.wav")
	
	if state == "JOGJA_ACTIVE" or state == "INTRO":
		if region_name == "Jogja":
			_enter_region("Jogja")
		else:
			_show_locked_dialogue()
	elif state == "CHOICES":
		if region_name == "Sumatra" or region_name == "Maluku":
			_enter_region(region_name)
		elif region_name == "Jogja":
			_enter_region("Jogja")
	elif state == "MALUKU_ACTIVE" or state == "POST_SUMATRA":
		if region_name == "Maluku":
			_enter_region("Maluku")
		else:
			_show_locked_dialogue()
	elif state == "POST_MALUKU":
		_enter_region(region_name)

func _show_locked_dialogue():
	var original_text = dialog_text.text
	dialog_text.text = "Sepertinya perjalanan kita belum sampai ke sana...\nKita perlu membuka jejak sebelumnya terlebih dahulu."
	var tree = get_tree()
	if not tree: return
	await tree.create_timer(2.5).timeout
	dialog_text.text = original_text

func _complete_jogja():
	if is_jogja_complete: return
	is_jogja_complete = true
	_start_post_jogja()

func _start_post_jogja():
	state = "POST_JOGJA"
	kirana_character.texture = load("res://assets/images/chars/char_kirana_map_excited.png")
	current_dialogue_list = dialogues_jogja_done
	current_dialogue_index = 0
	show_next_dialogue()

func _start_choices():
	state = "CHOICES"
	kirana_character.texture = load("res://assets/images/chars/char_kirana_map_guide.png")
	current_dialogue_list = dialogues_choices
	current_dialogue_index = 0
	show_next_dialogue()
	
	# Sumatra and Maluku now glow and are interactive
	sumatra_glow.visible = true
	maluku_glow.visible = true

func _start_post_sumatra():
	state = "POST_SUMATRA"
	kirana_character.texture = load("res://assets/images/chars/char_kirana_map_guide.png")
	current_dialogue_list = dialogues_sumatra_done
	current_dialogue_index = 0
	show_next_dialogue()
	
	# Only Maluku glows and is interactive
	jogja_glow.visible = false
	sumatra_glow.visible = false
	maluku_glow.visible = true

func _start_post_maluku():
	state = "POST_MALUKU"
	kirana_character.texture = load("res://assets/images/chars/char_kirana_map_excited.png")
	current_dialogue_list = dialogues_maluku_done
	current_dialogue_index = 0
	show_next_dialogue()
	
	# All regions glow at the end and are interactive
	jogja_glow.visible = true
	sumatra_glow.visible = true
	maluku_glow.visible = true

func _enter_region(region_name):
	var target_scene = "res://scenes/" + region_name + "Sequence.tscn"
	if ResourceLoader.exists(target_scene):
		get_tree().change_scene_to_file(target_scene)

var kembali_btn: TextureButton = null

func show_kembali_button():
	if has_node("RewardContainer/BtnMap"):
		return
		
	kembali_btn = TextureButton.new()
	
	var texture_path = "res://assets/images/button/selesai.png"
	if ResourceLoader.exists(texture_path):
		kembali_btn.texture_normal = load(texture_path)
		
	kembali_btn.ignore_texture_size = true
	kembali_btn.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	kembali_btn.custom_minimum_size = Vector2(320, 120)
	
	# Adjust dialog text right boundary to prevent overlapping with the button
	if dialog_text:
		dialog_text.offset_right = -360
	
	# add to DialogContainer
	dialog_container.add_child(kembali_btn)
	
	# Position bottom-right of DialogContainer
	kembali_btn.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	kembali_btn.anchor_left = 1.0
	kembali_btn.anchor_top = 1.0
	kembali_btn.anchor_right = 1.0
	kembali_btn.anchor_bottom = 1.0
	kembali_btn.offset_left = -340
	kembali_btn.offset_top = -135
	kembali_btn.offset_right = -20
	kembali_btn.offset_bottom = -15
	
	kembali_btn.pressed.connect(_on_kembali_pressed)
	
	# Fade in animation
	kembali_btn.modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(kembali_btn, "modulate:a", 1.0, 0.3)

func _on_kembali_pressed():
	_play_sfx("click_button.wav")
	await get_tree().create_timer(0.3).timeout
	get_tree().change_scene_to_file("res://scenes/GameComplete.tscn")

func _play_sfx(filename: String):
	GameManager.play_sfx(filename)

func _play_bgm(_base_name: String) -> void:
	GameManager.play_bgm("mainmenu_peta")
