extends Control

@onready var play_button = $PlayButton
@onready var animation_player = $AnimationPlayer
@onready var click_sfx = $ClickSFX
@onready var bgm = $BGM

var mouse_is_over_button: bool = false
var hover_tween: Tween

func _ready():
	# Start pulse animation
	animation_player.play("pulse")
	GameManager.play_bgm("mainmenu_peta")
	
	# Connect hover signals dynamically
	play_button.mouse_entered.connect(_on_play_button_mouse_entered)
	play_button.mouse_exited.connect(_on_play_button_mouse_exited)

func _on_play_button_mouse_entered():
	mouse_is_over_button = true
	
	# Stop idle pulse animation to allow manual tween modulate
	if animation_player.is_playing() and animation_player.current_animation == "pulse":
		animation_player.stop()
		
	# Kill existing tween if running
	if hover_tween:
		hover_tween.kill()
		
	# Create a beautiful gold modulate tween, keeping the button completely still
	hover_tween = create_tween()
	hover_tween.tween_property(play_button, "modulate", Color(1.15, 1.10, 0.92), 0.15).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func _on_play_button_mouse_exited():
	mouse_is_over_button = false
	
	# Kill existing tween if running
	if hover_tween:
		hover_tween.kill()
		
	# Tween back to standard modulate
	hover_tween = create_tween()
	hover_tween.tween_property(play_button, "modulate", Color(1.0, 1.0, 1.0), 0.15).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	# Once returned to normal, resume the soft idle breathing pulse
	hover_tween.tween_callback(func():
		if not mouse_is_over_button:
			animation_player.play("pulse")
	)

func _on_play_button_pressed():
	GameManager.play_sfx()
	
	# Disable the button to prevent multiple clicks during transition
	play_button.disabled = true
	
	# Start fade out and then change scene
	animation_player.play("fade_out")
	await animation_player.animation_finished
	
	var tree = get_tree()
	if tree:
		tree.change_scene_to_file("res://scenes/IntroLibrary.tscn")
