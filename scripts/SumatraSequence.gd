extends Control

@onready var video_player = $VideoStreamPlayer
@onready var character = $Character
@onready var dialog_container = $DialogContainer
@onready var dialog_text = $DialogContainer/DialogPanel/DialogText
@onready var btn_next = $DialogContainer/MulaiTantanganBtn

var current_step = 1
var dialogue_index = 0
var is_typing = false
var typing_speed = 0.05
var video_finished = false

var dialogues = {
	1: [
		"Di Sumatra Barat, masyarakat mulai menghadapi berbagai perubahan pada masa penjajahan.",
		"Semangat untuk mempertahankan nilai dan tanah air mulai tumbuh di tengah kehidupan masyarakat."
	],
	2: [
		"Para tokoh dan masyarakat mulai berdiskusi untuk menentukan langkah perjuangan.",
		"Mereka menyadari bahwa persatuan sangat penting dalam menghadapi penjajahan."
	],
	3: [
		"Perjuangan rakyat Sumatra Barat menjadi salah satu bagian penting dalam sejarah perlawanan Indonesia.",
		"Keberanian dan semangat mereka terus dikenang hingga sekarang.",
		"Sekarang, mari kita susun kembali perjalanan perjuangan rakyat Sumatra Barat melalui tantangan berikutnya!"
	]
}

func _ready():
	GameManager.stop_bgm()
	# UI hidden from start (cinematic mode)
	character.visible = false
	dialog_container.visible = false
	btn_next.visible = false
	
	_play_video("res://assets/videos/sumbar1.ogv")

func _play_video(path):
	video_finished = false
	GameManager.stop_bgm()
	# Hide UI during video playback
	character.visible = false
	dialog_container.visible = false
	
	video_player.stream = load(path)
	video_player.play()

func _on_video_stream_player_finished():
	# Show UI only after video finishes
	video_finished = true
	character.visible = true
	dialog_container.visible = true
	dialogue_index = 0
	GameManager.play_bgm("materi")
	_show_next_dialogue()

func _input(event):
	if event.is_action_pressed("ui_accept") or (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		if video_finished and dialog_container.visible and not btn_next.visible:
			_play_sfx("click.wav")
			if is_typing:
				is_typing = false
				dialog_text.visible_characters = -1
			else:
				_show_next_dialogue()

func _show_next_dialogue():
	var current_dialogues = dialogues[current_step]
	if dialogue_index < current_dialogues.size():
		is_typing = true
		dialog_text.text = current_dialogues[dialogue_index]
		dialog_text.visible_characters = 0
		
		while dialog_text.visible_characters < dialog_text.text.length():
			if not is_typing: break
			dialog_text.visible_characters += 1
			var tree = get_tree()
			if not tree: break
			await tree.create_timer(typing_speed).timeout
		
		is_typing = false
		dialogue_index += 1
	else:
		_on_dialogue_finished()

func _on_dialogue_finished():
	if current_step < 3:
		current_step += 1
		if current_step == 2:
			_play_video("res://assets/videos/sumbar2.ogv")
		elif current_step == 3:
			_play_video("res://assets/videos/sumbar 3.ogv")
	else:
		btn_next.visible = true

func _on_mulai_tantangan_btn_pressed():
	_play_sfx("click_button.wav")
	var tree = get_tree()
	if tree:
		tree.change_scene_to_file("res://scenes/MiniGameSumbar.tscn")

func _play_sfx(filename: String):
	GameManager.play_sfx(filename)

func _play_bgm(_base_name: String) -> void:
	pass # BGM dihapus sepenuhnya sesuai permintaan user

