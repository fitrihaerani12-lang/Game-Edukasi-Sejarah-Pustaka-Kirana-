extends Control

@onready var background = $Background
@onready var cards_container = $CardsContainer
@onready var slots_container = $SlotsContainer
@onready var btn_check = $BtnCheck
@onready var btn_reset = $BtnReset
@onready var guide_kirana = $GuideKirana
@onready var guide_popup = $GuideKirana/Popup
@onready var campfire = $Campfire
@onready var candle_l = $CandleLeft
@onready var candle_r = $CandleRight

@onready var guide_label = $GuideKirana/Popup/Label

var cards = []
var correct_sequence = [
	"card_sekolah.png",
	"card_diskusi.png",
	"card_persatuan.png",
	"card_budiutomo.png"
]

var current_order = [null, null, null, null]
var dialog_step = 0

func _ready():
	GameManager.play_bgm("game&kuis")
	_setup_ui()
	_setup_cards()
	_show_guide()
	_animate_fire()

func _setup_ui():
	if ResourceLoader.exists("res://assets/images/background/bg_mini_game.png"):
		background.texture = load("res://assets/images/background/bg_mini_game.png")
	
	btn_check.pressed.connect(_on_check_pressed)
	btn_reset.pressed.connect(_on_reset_pressed)
	
	# Initial state
	btn_check.disabled = true
	
	# Apply premium styles
	_apply_premium_style(btn_check, Color(0.2, 0.6, 0.2))
	_apply_premium_style(btn_reset, Color(0.7, 0.2, 0.2))
	
	# Apply font
	var font = load("res://assets/images/fonts/CrimsonText-Regular.ttf")
	if font:
		guide_label.add_theme_font_override("font", font)
		guide_label.add_theme_font_size_override("font_size", 18)
	
	# Apply fire shader
	var fire_shader = load("res://shaders/fire.gdshader")
	if fire_shader:
		var mat = ShaderMaterial.new()
		mat.shader = fire_shader
		campfire.material = mat
		candle_l.material = mat.duplicate()
		candle_r.material = mat.duplicate()

func _setup_cards():
	var card_names = ["card_sekolah.png", "card_diskusi.png", "card_persatuan.png", "card_budiutomo.png"]
	var shuffled_names = card_names.duplicate()
	while true:
		shuffled_names.shuffle()
		if shuffled_names != card_names:
			break
	
	# Clear existing
	for child in cards_container.get_children():
		child.queue_free()
	
	for c_name in shuffled_names:
		var card = TextureRect.new() # Use TextureRect for dragging
		var path = "res://assets/images/cards/" + c_name
		if ResourceLoader.exists(path):
			card.texture = load(path)
		card.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		card.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		card.custom_minimum_size = Vector2(150, 200)
		card.name = c_name.replace(".png", "")
		card.set_meta("card_id", c_name)
		card.mouse_filter = Control.MOUSE_FILTER_STOP
		card.set_script(load("res://scripts/DraggableCard.gd")) # Dynamically attach helper script
		cards_container.add_child(card)

# Helper script will call these on root
func _card_dragged(card):
	return card

func _can_drop_in_slot(at_position, data):
	return data is TextureRect and data.has_meta("card_id")

func _drop_in_slot(slot_index, data):
	_place_card_in_slot(data, slot_index)

func _get_drag_data(at_position):
	if guide_popup and guide_popup.visible:
		return null
		
	var card = _get_card_at(at_position)
	if not card: return null
	
	var preview = TextureRect.new()
	preview.texture = card.texture
	preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview.size = Vector2(120, 160)
	preview.modulate.a = 0.7
	set_drag_preview(preview)
	
	return card

func _get_card_at(pos):
	for card in cards_container.get_children():
		if card.get_global_rect().has_point(get_global_mouse_position()):
			return card
	return null

func _can_drop_data(at_position, data):
	return data is TextureRect

func _drop_data(at_position, data):
	for i in range(4):
		var slot = slots_container.get_child(i)
		if slot.get_global_rect().has_point(get_global_mouse_position()):
			if current_order[i] == null:
				_place_card_in_slot(data, i)
				return

func _place_card_in_slot(card, slot_index):
	current_order[slot_index] = card.get_meta("card_id")
	card.visible = false # Hide from source
	
	var slot = slots_container.get_child(slot_index)
	var display = slot.get_node("Display")
	display.texture = card.texture
	display.visible = true
	
	_check_if_all_filled()

func _check_if_all_filled():
	var filled = true
	for item in current_order:
		if item == null:
			filled = false
			break
	btn_check.disabled = not filled

func _on_check_pressed():
	var is_correct = true
	for i in range(4):
		if current_order[i] != correct_sequence[i]:
			is_correct = false
			break
	
	if is_correct:
		_play_sfx("click_button.wav")
		guide_kirana.texture = load("res://assets/images/chars/char_kirana_map_excited.png")
		guide_label.text = "Kamu berhasil, ayo kita menuju ke kuis untuk membuka wilayah berikutnya!"
		guide_kirana.visible = true
		guide_popup.visible = true
		
		await get_tree().create_timer(2.5).timeout
		get_tree().change_scene_to_file("res://scenes/JogjaQuiz.tscn")
	else:
		_play_sfx("click_button.wav")
		guide_kirana.texture = load("res://assets/images/chars/char_kirana_materi.png")
		guide_label.text = "Sepertinya kamu keliru sedikit, ayo perbaiki lagi!"
		guide_kirana.visible = true
		guide_popup.visible = true
		
		await get_tree().create_timer(2.0).timeout
		_on_reset_pressed()

func _on_reset_pressed():
	_play_sfx("click_button.wav")
	current_order = [null, null, null, null]
	btn_check.disabled = true
	
	# Restore guide image
	guide_kirana.texture = load("res://assets/images/chars/char_kirana_map_guide.png")
	guide_kirana.visible = false
	guide_popup.visible = false
	
	for i in range(4):
		var slot = slots_container.get_child(i)
		slot.get_node("Display").visible = false
	
	for card in cards_container.get_children():
		card.visible = true

func _show_guide():
	guide_kirana.visible = true
	guide_popup.visible = true
	guide_kirana.texture = load("res://assets/images/chars/char_kirana_map_guide.png")
	
	dialog_step = 0
	_update_dialog()
	
	guide_popup.mouse_filter = Control.MOUSE_FILTER_STOP
	if not guide_popup.gui_input.is_connected(_on_popup_gui_input):
		guide_popup.gui_input.connect(_on_popup_gui_input)
		
	guide_kirana.mouse_filter = Control.MOUSE_FILTER_STOP
	if not guide_kirana.gui_input.is_connected(_on_popup_gui_input):
		guide_kirana.gui_input.connect(_on_popup_gui_input)

func _update_dialog():
	if dialog_step == 0:
		guide_label.text = "Sekarang giliran kita menyusun kembali perjalanan awal kebangkitan nasional."
	elif dialog_step == 1:
		guide_label.text = "Susun peristiwa-peristiwa berikut dari urutan yang paling awal hingga yang terakhir!"
	else:
		guide_popup.visible = false
		guide_kirana.visible = false

func _on_popup_gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		dialog_step += 1
		_update_dialog()

func _animate_fire():
	# Create a flickering effect for campfire and candles
	var tween = create_tween().set_loops()
	tween.tween_property(campfire, "modulate:a", 0.7, 0.1)
	tween.tween_property(campfire, "modulate:a", 1.0, 0.1)
	tween.parallel().tween_property(campfire, "scale", Vector2(1.05, 1.05), 0.15)
	tween.tween_property(campfire, "scale", Vector2(1.0, 1.0), 0.15)
	
	var tween_c = create_tween().set_loops()
	tween_c.tween_property(candle_l, "modulate", Color(1.2, 1.1, 0.8), 0.2)
	tween_c.tween_property(candle_l, "modulate", Color(1.0, 1.0, 1.0), 0.2)
	
	var tween_r = create_tween().set_loops()
	tween_r.tween_property(candle_r, "modulate", Color(1.2, 1.1, 0.8), 0.25)
	tween_r.tween_property(candle_r, "modulate", Color(1.0, 1.0, 1.0), 0.25)

func _apply_premium_style(btn: Button, color: Color):
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0,0,0,0) # Transparent to show background text
	style.border_width_bottom = 0
	
	var hover = StyleBoxFlat.new()
	hover.bg_color = Color(1, 1, 1, 0.1) # Subtle hover effect
	hover.corner_radius_top_left = 10
	hover.corner_radius_top_right = 10
	hover.corner_radius_bottom_left = 10
	hover.corner_radius_bottom_right = 10
	
	var disabled = StyleBoxFlat.new()
	disabled.bg_color = Color(0, 0, 0, 0.3) # Darker when disabled
	
	btn.add_theme_stylebox_override("normal", style)
	btn.add_theme_stylebox_override("hover", hover)
	btn.add_theme_stylebox_override("pressed", hover)
	btn.add_theme_stylebox_override("disabled", disabled)
	btn.text = "" # Remove text so only background text shows

func _play_sfx(filename: String):
	GameManager.play_sfx(filename)
