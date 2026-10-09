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
		"Maluku dikenal sebagai daerah penghasil rempah-rempah yang sangat berharga.",
		"Kekayaan alam ini menarik perhatian bangsa-bangsa asing untuk datang ke Nusantara."
	],
	2: [
		"Bangsa asing mulai menguasai perdagangan rempah di Maluku.",
		"Hal ini membawa banyak perubahan dalam kehidupan masyarakat."
	],
	3: [
		"Masyarakat Maluku tidak tinggal diam menghadapi kolonialisme.",
		"Mereka menunjukkan keberanian dan semangat perjuangan demi mempertahankan tanah air.",
		"Sekarang, mari kita susun kembali perjalanan sejarah Maluku melalui tantangan berikutnya!"
	]
}

func _ready():
	GameManager.stop_bgm()
	# UI hidden from start (cinematic mode)
	character.visible = false
	dialog_container.visible = false
	btn_next.visible = false
	
	# Set linear filtering to make video rendering smoother and less pixelated/blurry
	video_player.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	
	_play_video("res://assets/videos/maluku1.ogv")

func _process(_delta):
	if video_player.is_playing() and not video_finished:
		var pos = video_player.stream_position
		var length = video_player.get_stream_length()
		# Pause the video slightly before the absolute end to keep the last frame visible
		if length > 0.0 and pos >= length - 0.15:
			_on_video_reached_end()

func _play_video(path):
	video_finished = false
	GameManager.stop_bgm()
	# Hide UI during video playback
	character.visible = false
	dialog_container.visible = false
	
	video_player.stream = load(path)
	video_player.paused = false
	video_player.play()

func _on_video_stream_player_finished():
	if not video_finished:
		_on_video_reached_end()

func _on_video_reached_end():
	video_finished = true
	video_player.paused = true # Freeze on the last frame
	
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
			_play_video("res://assets/videos/maluku2.ogv")
		elif current_step == 3:
			_play_video("res://assets/videos/maluku3.ogv")
	else:
		btn_next.visible = true

func _on_mulai_tantangan_btn_pressed():
	_play_sfx("click_button.wav")
	var tree = get_tree()
	if tree:
		tree.change_scene_to_file("res://scenes/MiniGameMaluku.tscn")

func _play_sfx(filename: String):
	GameManager.play_sfx(filename)

func _play_bgm(_base_name: String) -> void:
	pass # BGM dihapus sepenuhnya sesuai permintaan user

