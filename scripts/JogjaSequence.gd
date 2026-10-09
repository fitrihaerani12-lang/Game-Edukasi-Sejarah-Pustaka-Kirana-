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
		"Di tempat seperti inilah, para pemuda dari berbagai daerah mulai berkumpul untuk belajar.",
		"Meskipun berasal dari latar belakang yang berbeda, mereka memiliki harapan yang sama… yaitu membawa perubahan bagi masa depan bangsa"
	],
	2: [
		"Seiring waktu, mereka mulai menyadari bahwa perjuangan tidak hanya dilakukan dengan kekuatan fisik…",
		"Tetapi juga melalui pendidikan, pemikiran, dan semangat persatuan."
	],
	3: [
		"Dari semangat belajar dan kebersamaan inilah, lahir sebuah gerakan baru yang menjadi awal kebangkitan nasional.",
		"Gerakan tersebut dikenal sebagai Budi Utomo, organisasi modern pertama di Indonesia.",
		"Sekarang, mari kita susun kembali perjalanan awal kebangkitan nasional melalui tantangan berikutnya.",
		"Susun peristiwa-peristiwa tadi dari awal hingga akhir dengan urutan yang tepat!"
	]
}

func _ready():
	GameManager.stop_bgm()
	# UI hidden from start (cinematic mode)
	character.visible = false
	dialog_container.visible = false
	btn_next.visible = false
	
	_play_video("res://assets/videos/jogja1.ogv")

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
		_play_video("res://assets/videos/jogja" + str(current_step) + ".ogv")
	else:
		btn_next.visible = true

func _on_mulai_tantangan_btn_pressed():
	_play_sfx("click_button.wav")
	var tree = get_tree()
	if tree:
		tree.change_scene_to_file("res://scenes/MiniGameJogja.tscn")

func _play_sfx(filename: String):
	GameManager.play_sfx(filename)

func _play_bgm(_base_name: String) -> void:
	pass # BGM dihapus sepenuhnya sesuai permintaan user

