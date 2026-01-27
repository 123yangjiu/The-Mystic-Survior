extends Button

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var fullscreen: Label = $Fullscreen
@onready var window: Label = $Window


func _ready() -> void:
	if DisplayServer.window_get_mode() !=3:
		to_window(0)
		animated_sprite_2d.frame =0
	else :
		to_fullscreen(0)
		animated_sprite_2d.frame =8

func _on_button_up() -> void:
	var screen := DisplayServer.window_get_mode()
	if screen !=3:
		to_fullscreen()
	else:
		to_window()

func _on_animated_sprite_2d_animation_finished() -> void:
	animated_sprite_2d.pause()

func to_fullscreen(time=0.4)->void:
	var tween = create_tween().set_parallel().set_ease(Tween.EASE_IN_OUT)
	animated_sprite_2d.play("default")
	tween.tween_property(window,"modulate",Color(0.0, 0.0, 0.0, 1.0),time)
	tween.tween_property(fullscreen,"modulate",Color(1.0, 1.0, 1.0, 1.0),time)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
func to_window(time=0.4)->void:
	var tween = create_tween().set_parallel().set_ease(Tween.EASE_IN_OUT)
	animated_sprite_2d.play_backwards("default")
	tween.tween_property(window,"modulate",Color(1.0, 1.0, 1.0, 1.0),time)
	tween.tween_property(fullscreen,"modulate",Color(0.0, 0.0, 0.0, 1.0),time)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
