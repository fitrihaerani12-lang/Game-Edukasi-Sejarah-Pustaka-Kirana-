extends Node

var total_points: int = 0
var is_jogja_completed: bool = false
var is_sumatra_completed: bool = false
var is_maluku_completed: bool = false

func _ready():
	randomize()

func add_points(amount: int):
	total_points += amount
	print("Poin bertambah! Total sekarang: ", total_points)

func reset_points():
	total_points = 0

# --- SISTEM AUDIO GLOBAL ---

var bgm_player: AudioStreamPlayer = null
var current_bgm: String = ""

func play_bgm(base_name: String) -> void:
	print("[Audio Manager] play_bgm requested with keyword: '", base_name, "'")
	
	# Normalize key names to match our premium assets
	var clean_name = base_name.to_lower().strip_edges()
	if clean_name == "mainmenu_peta" or clean_name == "mainmenu" or clean_name == "bgm_map" or clean_name == "bgm_library":
		clean_name = "mainmenu_peta"
	elif clean_name == "game&kuis" or clean_name == "game_kuis" or clean_name == "game" or clean_name == "bgm_quiz":
		clean_name = "game&kuis"
	elif clean_name == "materi":
		clean_name = "materi"

	if current_bgm == clean_name:
		print("[Audio Manager] BGM '", clean_name, "' is already active.")
		# Already playing, ensure it's unpaused if needed and return
		if bgm_player and not bgm_player.playing:
			bgm_player.play()
			print("[Audio Manager] Resumed BGM: '", clean_name, "'")
		return
	
	stop_bgm()
	
	var filename = ""
	if clean_name == "mainmenu_peta":
		filename = "mainmenu_peta-converted.wav"
	elif clean_name == "game&kuis":
		filename = "game&kuis-converted.wav"
	elif clean_name == "materi":
		filename = "materi-converted.wav"
	else:
		filename = base_name
		if not filename.ends_with(".wav"):
			filename += ".wav"
			
	var path = "res://assets/audio/bgm/" + filename
	print("[Audio Manager] Checking BGM file path: '", path, "'")
	
	if ResourceLoader.exists(path):
		var stream = load(path)
		if stream:
			bgm_player = AudioStreamPlayer.new()
			bgm_player.stream = stream
			bgm_player.volume_db = -10.0 # Standard BGM volume
			add_child(bgm_player)
			bgm_player.play()
			current_bgm = clean_name
			print("[Audio Manager] SUCCESS: Playing looped BGM: '", path, "'")
		else:
			printerr("[Audio Manager] ERROR: Failed to load BGM resource: '", path, "'")
	else:
		printerr("[Audio Manager] ERROR: BGM file does not exist in resource database: '", path, "'")

func stop_bgm() -> void:
	if bgm_player:
		print("[Audio Manager] Stopping current BGM: '", current_bgm, "'")
		bgm_player.stop()
		bgm_player.queue_free()
		bgm_player = null
	current_bgm = ""

func play_sfx(filename: String = "click.wav") -> void:
	print("[Audio Manager] play_sfx requested: '", filename, "'")
	
	var clean_name = filename.to_lower()
	var real_filename = "click-converted.wav"
	
	if "reward" in clean_name:
		real_filename = "Reward-converted.wav"
	elif "click" in clean_name:
		real_filename = "click-converted.wav"
	else:
		real_filename = filename
		if not real_filename.ends_with(".wav"):
			real_filename += ".wav"
			
	var path = "res://assets/audio/sfx/" + real_filename
	print("[Audio Manager] Checking SFX file path: '", path, "'")
	
	if ResourceLoader.exists(path):
		var stream = load(path)
		if stream:
			var player = AudioStreamPlayer.new()
			player.stream = stream
			
			# Dynamic volume boost
			var sfx_volume = 0.0 # 0.0 dB is full unattenuated volume (louder than -12.0 dB)
			if "reward" in clean_name:
				sfx_volume = 4.0 # Boost the reward sparkles above the BGM
				
			player.volume_db = sfx_volume
			add_child(player)
			player.play()
			player.finished.connect(player.queue_free)
			print("[Audio Manager] SUCCESS: Playing SFX: '", path, "' at volume: ", sfx_volume, " dB")
		else:
			printerr("[Audio Manager] ERROR: Failed to load SFX resource: '", path, "'")
	else:
		printerr("[Audio Manager] ERROR: SFX file does not exist in resource database, looking for fallback...")
		# Fallback to click if not found
		var fallback_path = "res://assets/audio/sfx/click-converted.wav"
		if ResourceLoader.exists(fallback_path):
			var stream = load(fallback_path)
			if stream:
				var player = AudioStreamPlayer.new()
				player.stream = stream
				player.volume_db = 0.0 # Standard original volume
				add_child(player)
				player.play()
				player.finished.connect(player.queue_free)
				print("[Audio Manager] SUCCESS: Playing fallback click SFX: '", fallback_path, "' at 0.0 dB")
			else:
				printerr("[Audio Manager] ERROR: Failed to load fallback click SFX: '", fallback_path, "'")
		else:
			printerr("[Audio Manager] ERROR: Fallback click SFX does not exist on disk!")


