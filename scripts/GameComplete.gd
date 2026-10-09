extends Control

@onready var background = $Background
@onready var dialog_text = $DialogContainer/DialogPanel/DialogText
@onready var start_button = $DialogContainer/StartButton
@onready var kirana_sprite = $Kirana
@onready var click_sfx = $ClickSFX
@onready var text_sfx = $TextSFX
@onready var bgm = $BGM

# New reward elements
@onready var dialog_container = $DialogContainer
@onready var reward_container = $RewardContainer
@onready var star_left = $RewardContainer/StarLeft
@onready var star_center = $RewardContainer/StarCenter
@onready var star_right = $RewardContainer/StarRight
@onready var particles_left = $RewardContainer/StarLeft/Particles
@onready var particles_center = $RewardContainer/StarCenter/Particles
@onready var particles_right = $RewardContainer/StarRight/Particles
@onready var title_label = $RewardContainer/TitleLabel
@onready var btn_map = $RewardContainer/BtnMap
@onready var btn_selesai = $RewardContainer/BtnSelesai

var dialogues = [
	"Seluruh perjalanan telah tersimpan kembali di dalam Pustaka Kirana.",
	"Kini, sejarah Nusantara akan terus hidup dan dapat dipelajari kembali kapan saja."
]

var current_dialogue_index = 0
var is_typing = false
var typing_speed = 0.05
var is_sequence_active = false
var btn_tweens = {}

func _ready():
	start_button.hide()
	reward_container.hide()
	dialog_text.text = ""
	
	# Set a nice subtle glow for the completed book!
	if background.material:
		background.material.set_shader_parameter("glow_intensity", 0.5)
		background.material.set_shader_parameter("time_speed", 2.0)
	
	if kirana_sprite.has_method("set_expression"):
		kirana_sprite.set_expression("EXCITED")
	elif kirana_sprite.has_node("Kirana"):
		var actual_kirana = kirana_sprite.get_node("Kirana")
		if actual_kirana and actual_kirana.has_method("set_expression"):
			actual_kirana.set_expression("EXCITED")
			
	GameManager.play_bgm("mainmenu_peta")
		
	# Connect reward button hover and clicked signals dynamically
	btn_map.pressed.connect(_on_btn_map_pressed)
	btn_selesai.pressed.connect(_on_btn_selesai_pressed)
	
	btn_map.mouse_entered.connect(_on_btn_hover_entered.bind(btn_map))
	btn_map.mouse_exited.connect(_on_btn_hover_exited.bind(btn_map))
	
	btn_selesai.mouse_entered.connect(_on_btn_hover_entered.bind(btn_selesai))
	btn_selesai.mouse_exited.connect(_on_btn_hover_exited.bind(btn_selesai))
	
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
		elif current_dialogue_index >= dialogues.size():
			GameManager.play_sfx()
			# Dialogues fully completed, start the gorgeous reward sekuens!
			set_process_input(false) # Disable input to prevent double-clicks
			start_ending_sequence()


func show_next_dialogue():
	if current_dialogue_index >= dialogues.size():
		return
		
	is_typing = true
	dialog_text.text = dialogues[current_dialogue_index]
	dialog_text.visible_characters = 0
	
	# Typing effect
	while dialog_text.visible_characters < dialog_text.text.length():
		if not is_typing: break
		dialog_text.visible_characters += 1
		await get_tree().create_timer(typing_speed).timeout
	
	is_typing = false
	current_dialogue_index += 1

func start_ending_sequence():
	if is_sequence_active: return
	is_sequence_active = true
	
	# 1. Fade out dialogue box and Kirana character
	var fade_ui = create_tween().set_parallel(true)
	fade_ui.tween_property(dialog_container, "modulate:a", 0.0, 0.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	fade_ui.tween_property(kirana_sprite, "modulate:a", 0.0, 0.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	await fade_ui.finished
	dialog_container.hide()
	kirana_sprite.hide()
	
	# 2. Focus camera on book and increase shader glow
	background.pivot_offset = Vector2(640, 360) # screen center
	var focus_tween = create_tween().set_parallel(true)
	focus_tween.tween_property(background, "scale", Vector2(1.22, 1.22), 2.0).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	if background.material:
		focus_tween.tween_property(background.material, "shader_parameter/glow_intensity", 1.2, 2.0).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		
	# 3. Initialize reward elements (hidden)
	reward_container.modulate.a = 1.0
	reward_container.show()
	
	star_left.scale = Vector2.ZERO
	star_center.scale = Vector2.ZERO
	star_right.scale = Vector2.ZERO
	star_left.modulate.a = 0.0
	star_center.modulate.a = 0.0
	star_right.modulate.a = 0.0
	
	title_label.modulate.a = 0.0
	title_label.scale = Vector2(0.9, 0.9)
	title_label.pivot_offset = Vector2(640, 40) # Center of the title label's rect
	
	btn_map.modulate.a = 0.0
	btn_selesai.modulate.a = 0.0
	
	# Wait for camera focus to establish slightly
	await get_tree().create_timer(1.0).timeout
	
	# 4. Sequentially pop stars
	# Pop Left Star
	var pop_left = create_tween().set_parallel(true)
	pop_left.tween_property(star_left, "scale", Vector2(1.0, 1.0), 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	pop_left.tween_property(star_left, "modulate:a", 1.0, 0.2)
	_play_sfx("Reward")
	particles_left.emitting = true
	
	await get_tree().create_timer(0.4).timeout
	
	# Pop Center Star (Main achievement!)
	var pop_center = create_tween().set_parallel(true)
	pop_center.tween_property(star_center, "scale", Vector2(1.0, 1.0), 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	pop_center.tween_property(star_center, "modulate:a", 1.0, 0.2)
	_play_sfx("Reward")
	particles_center.emitting = true
	
	await get_tree().create_timer(0.4).timeout
	
	# Pop Right Star
	var pop_right = create_tween().set_parallel(true)
	pop_right.tween_property(star_right, "scale", Vector2(1.0, 1.0), 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	pop_right.tween_property(star_right, "modulate:a", 1.0, 0.2)
	_play_sfx("Reward")
	particles_right.emitting = true
	
	await get_tree().create_timer(0.6).timeout
	
	# 5. Fade In Title
	var title_tween = create_tween().set_parallel(true)
	title_tween.tween_property(title_label, "modulate:a", 1.0, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	title_tween.tween_property(title_label, "scale", Vector2(1.0, 1.0), 1.0).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	
	await get_tree().create_timer(0.6).timeout
	
	# 6. Fade In Choice Buttons
	var btn_tween = create_tween().set_parallel(true)
	btn_tween.tween_property(btn_map, "modulate:a", 1.0, 0.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	btn_tween.tween_property(btn_selesai, "modulate:a", 1.0, 0.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func _on_btn_hover_entered(btn: TextureButton):
	if btn.disabled: return
	if btn_tweens.has(btn) and btn_tweens[btn]:
		btn_tweens[btn].kill()
		
	var tween = create_tween()
	tween.tween_property(btn, "modulate", Color(1.15, 1.10, 0.92), 0.15).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	btn_tweens[btn] = tween

func _on_btn_hover_exited(btn: TextureButton):
	if btn_tweens.has(btn) and btn_tweens[btn]:
		btn_tweens[btn].kill()
		
	var tween = create_tween()
	tween.tween_property(btn, "modulate", Color(1.0, 1.0, 1.0), 0.15).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	btn_tweens[btn] = tween

func _on_btn_map_pressed():
	_play_sfx("click_button.wav")
	btn_map.disabled = true
	btn_selesai.disabled = true
	
	var fade = create_tween()
	fade.tween_property(reward_container, "modulate:a", 0.0, 0.5)
	await fade.finished
	
	get_tree().change_scene_to_file("res://scenes/MapScene.tscn")

func _on_btn_selesai_pressed():
	_play_sfx("click_button.wav")
	btn_map.disabled = true
	btn_selesai.disabled = true
	
	var fade = create_tween()
	fade.tween_property(reward_container, "modulate:a", 0.0, 0.5)
	await fade.finished
	
	# Reset all completion states so they can replay!
	GameManager.is_jogja_completed = false
	GameManager.is_sumatra_completed = false
	GameManager.is_maluku_completed = false
	GameManager.reset_points()
	
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")

func _play_sfx(filename: String):
	GameManager.play_sfx(filename)


