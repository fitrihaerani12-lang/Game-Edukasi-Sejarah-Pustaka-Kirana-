extends Control

@onready var main_panel = $MainPanel
@onready var progress_label = $MainPanel/ProgressLabel
@onready var main_label = $MainPanel/MainLabel

@onready var choice_0 = $MainPanel/Choice0
@onready var choice_1 = $MainPanel/Choice1
@onready var choice_2 = $MainPanel/Choice2
@onready var choices_nodes = [choice_0, choice_1, choice_2]

@onready var btn_kiri = $BtnKiri
@onready var btn_kanan = $BtnKanan

var user_answers = [-1, -1, -1, -1]
var current_step = 0

var questions = [
	{
		"question": "Apa yang mulai tumbuh di tengah masyarakat Sumatra Barat pada masa penjajahan?",
		"choices": ["Semangat mempertahankan tanah air", "Keinginan memperluas wilayah", "Persaingan perdagangan"],
		"correct": 0
	},
	{
		"question": "Mengapa para tokoh dan masyarakat mulai berdiskusi bersama?",
		"choices": ["Untuk menentukan langkah perjuangan", "Untuk mencari kekuasaan", "Untuk memperbesar perdagangan"],
		"correct": 0
	},
	{
		"question": "Apa yang dianggap penting dalam menghadapi penjajahan?",
		"choices": ["Persatuan", "Persaingan", "Kekayaan daerah"],
		"correct": 0
	},
	{
		"question": "Bagaimana rakyat Sumatra Barat dikenang dalam sejarah Indonesia?",
		"choices": ["Karena keberanian dan semangat perjuangannya", "Karena perdagangan rempah", "Karena perebutan kekuasaan"],
		"correct": 0
	}
]

var intro_dialog = "Hebat! Kamu berhasil menyusun kembali perjalanan perjuangan rakyat Sumatra Barat.\n\nSekarang, ayo uji kembali pemahamanmu melalui beberapa pertanyaan berikut!"

func _ready():
	_play_bgm("bgm_quiz")
	# Connect navigation buttons
	if btn_kiri is TextureButton:
		btn_kiri.pressed.connect(_on_btn_kiri_pressed)
	if btn_kanan is TextureButton:
		btn_kanan.pressed.connect(_on_btn_kanan_pressed)
		
	# Connect existing choice buttons
	for i in range(choices_nodes.size()):
		var btn = choices_nodes[i]
		if btn is Button:
			btn.pressed.connect(func(): _on_choice_selected(i))

	current_step = 0
	_update_ui_for_step()

func _update_ui_for_step():
	var tween = create_tween()
	tween.tween_property(main_panel, "modulate:a", 0.0, 0.15)
	tween.tween_callback(func():
		_apply_step_logic()
		var t2 = create_tween()
		t2.tween_property(main_panel, "modulate:a", 1.0, 0.15)
	)

func _apply_step_logic():
	# Step 0: Intro
	# Step 1: Q1
	# Step 2: Q2
	# Step 3: Q3
	# Step 4: Q4
	# Step 5: Result
	
	btn_kiri.visible = (current_step > 0)
	btn_kanan.visible = true
	btn_kanan.modulate = Color(1, 1, 1)
	
	if current_step == 0:
		# Intro dialog
		progress_label.hide()
		for btn in choices_nodes:
			btn.hide()
		main_label.text = intro_dialog
		
	elif current_step >= 1 and current_step <= 4:
		# Quiz questions
		progress_label.show()
		
		var score = _calculate_score()
		progress_label.text = str(score) + "/4"
		
		var q_idx = current_step - 1
		var q = questions[q_idx]
		main_label.text = q["question"]
		
		var selected_choice = user_answers[q_idx]
		
		if selected_choice == -1:
			btn_kanan.modulate = Color(0.5, 0.5, 0.5) # Disabled look
			
		for i in range(choices_nodes.size()):
			var btn = choices_nodes[i]
			if i < q["choices"].size():
				btn.text = q["choices"][i]
				btn.show()
			else:
				btn.hide()
			
			if i == selected_choice:
				_highlight_button(btn)
			else:
				btn.remove_theme_stylebox_override("normal")
					
	elif current_step == 5:
		# Result
		progress_label.hide()
		for btn in choices_nodes:
			btn.hide()
		
		var score = _calculate_score()
		if score >= 3:
			main_label.text = "Skor Kamu: " + str(score) + "/4\n\nHebat! Kamu berhasil memahami perjuangan rakyat Sumatra Barat.\n\nSekarang, mari lanjutkan perjalanan ke wilayah berikutnya!"
		else:
			main_label.text = "Skor Kamu: " + str(score) + "/4\n\nSepertinya masih ada beberapa bagian sejarah yang belum tepat...\n\nYuk, coba lagi dan perhatikan setiap pertanyaannya dengan baik!"
			btn_kanan.visible = false

func _highlight_button(btn: Button):
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.4, 0.25, 0.15, 1.0)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = Color(1.0, 0.85, 0.5)
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_right = 8
	style.corner_radius_bottom_left = 8
	style.content_margin_top = 12
	style.content_margin_bottom = 12
	btn.add_theme_stylebox_override("normal", style)

func _calculate_score():
	var score = 0
	var max_q_idx = current_step - 1
	for i in range(min(max_q_idx, questions.size())):
		if user_answers[i] == questions[i]["correct"]:
			score += 1
	return score

func _on_choice_selected(index):
	if current_step >= 1 and current_step <= 4:
		var q_idx = current_step - 1
		user_answers[q_idx] = index
		_play_sfx("click_button.wav")
		
		btn_kanan.modulate = Color(1, 1, 1)
		
		# Refresh UI highlights
		for i in range(choices_nodes.size()):
			var btn = choices_nodes[i]
			if i == index:
				_highlight_button(btn)
			else:
				btn.remove_theme_stylebox_override("normal")

func _on_btn_kiri_pressed():
	if current_step > 0:
		_play_sfx("click_button.wav")
		if current_step == 5:
			var score = _calculate_score()
			if score < 3:
				current_step = 1 # Kembali ke Soal 1
				user_answers = [-1, -1, -1, -1] # Reset jawaban
			else:
				current_step = 4 # Kembali ke soal terakhir jika lulus
		else:
			current_step -= 1
		_update_ui_for_step()

func _on_btn_kanan_pressed():
	_play_sfx("click_button.wav")
	
	if current_step >= 1 and current_step <= 4:
		var q_idx = current_step - 1
		if user_answers[q_idx] == -1:
			return # Must answer first
			
	if current_step < 5:
		current_step += 1
		_update_ui_for_step()
	elif current_step == 5:
		var score = _calculate_score()
		if score >= 3:
			GameManager.is_sumatra_completed = true
			get_tree().change_scene_to_file("res://scenes/MapScene.tscn")

func _play_sfx(filename: String):
	GameManager.play_sfx(filename)

func _play_bgm(_base_name: String) -> void:
	GameManager.play_bgm("game&kuis")

