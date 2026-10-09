extends Control

@onready var background = $Background
@onready var dialog_text = $DialogContainer/DialogPanel/DialogText
@onready var start_button = $DialogContainer/StartButton
@onready var kirana_sprite = $Kirana
@onready var animation_player = $AnimationPlayer
@onready var click_sfx = $ClickSFX
@onready var text_sfx = $TextSFX
@onready var bgm = $BGM

var dialogues = [
	"Halo! Aku Kirana, Sang Pemandu Sejarah Nusantara.",
	"Coba perhatikan buku ajaib yang bersinar di belakangku itu. Sayangnya, seluruh halamannya saat ini kosong...",
	"Hal itu terjadi karena kepingan sejarah masa lalu bangsa kita telah memudar dan tersebar ke berbagai penjuru.",
	"Maukah kamu bertualang bersamaku untuk mengumpulkan dan menyusun kembali sejarah nusantara yang hilang?"
]

var current_dialogue_index = 0
var is_typing = false
var typing_speed = 0.05

func _ready():
	start_button.hide()
	dialog_text.text = ""
	
	GameManager.play_bgm("mainmenu_peta")
			
	# Set initial soft glow
	if background.material:
		background.material.set_shader_parameter("glow_intensity", 0.4)
	
	await get_tree().create_timer(0.5).timeout
	show_next_dialogue()

func _input(event):
	if event.is_action_pressed("ui_accept") or (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		if is_typing or current_dialogue_index < dialogues.size():
			GameManager.play_sfx()
			if is_typing:
				# Skip typing
				is_typing = false
				dialog_text.visible_characters = -1
			else:
				show_next_dialogue()

func show_next_dialogue():
	if current_dialogue_index >= dialogues.size():
		return
		
	is_typing = true
	dialog_text.text = dialogues[current_dialogue_index]
	dialog_text.visible_characters = 0
	
	# Visual feedback for specific dialogues
	if current_dialogue_index == 1: # Mentioning the book
		pass # glow sudah diterapkan, tidak ada perubahan visual tambahan
	
	# Typing effect
	while dialog_text.visible_characters < dialog_text.text.length():
		if not is_typing: break
		dialog_text.visible_characters += 1
		await get_tree().create_timer(typing_speed).timeout
	
	is_typing = false
	current_dialogue_index += 1
	
	if current_dialogue_index == dialogues.size():
		show_start_button()

func increase_glow():
	if background.material:
		var tween = create_tween()
		tween.tween_property(background.material, "shader_parameter/glow_intensity", 1.0, 0.8)

func show_start_button():
	start_button.modulate.a = 0
	start_button.show()
	var tween = create_tween()
	tween.tween_property(start_button, "modulate:a", 1.0, 0.5)

func _on_start_button_pressed():
	GameManager.play_sfx()
	var tree = get_tree()
	if tree:
		tree.change_scene_to_file("res://scenes/MapScene.tscn")

