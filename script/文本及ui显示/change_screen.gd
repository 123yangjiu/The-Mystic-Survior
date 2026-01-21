extends Button

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var fullscreen: Label = $Fullscreen
@onready var window: Label = $Window


func _ready() -> void:
	if DisplayServer.window_get_mode() !=3 or DisplayServer.window_get_mode() !=4 :
		animated_sprite_2d.frame =0
	else :
		animated_sprite_2d.frame =8

func _on_button_up() -> void:
	var screen := DisplayServer.window_get_mode()
	var tween = create_tween().set_parallel().set_ease(Tween.EASE_IN_OUT)
	if screen !=3 or screen !=4:
		animated_sprite_2d.play("default")
		tween.tween_property(window,"modulate",Color(0.0, 0.0, 0.0, 1.0),0.4)
		tween.tween_property(fullscreen,"modulate",Color(1.0, 1.0, 1.0, 1.0),0.4)
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		animated_sprite_2d.play_backwards("default")
		tween.tween_property(window,"modulate",Color(1.0, 1.0, 1.0, 1.0),0.4)
		tween.tween_property(fullscreen,"modulate",Color(0.0, 0.0, 0.0, 1.0),0.4)
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _on_animated_sprite_2d_animation_finished() -> void:
	animated_sprite_2d.pause()
	pass # Replace with function body.
