class_name ChangeButton
extends Button

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var right: Label = $Right
@onready var left: Label =$Left
var check_target

func _ready() -> void:
	set_check()
	to_initial()

func set_check()->void:
	check_target=3

func get_check_object():
	return DisplayServer.window_get_mode()

func _on_button_up() -> void:
	var screen = get_check_object()
	if screen !=check_target:
		taeget_effect()
		target()
	else:
		back_effect()
		back()

func to_initial()->void:
	self.button_up.connect(_on_button_up)
	if get_check_object()==check_target:
		target()
		taeget_effect(0)
	else :
		back()
		back_effect(0)

func target()->void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

func back()->void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func taeget_effect(time=0.4)->void:
	var tween = create_tween().set_parallel().set_ease(Tween.EASE_IN_OUT)
	if time !=0:
		animated_sprite_2d.play("default")
	else :
		animated_sprite_2d.frame =8
	tween.tween_property(left,"modulate",Color(0.0, 0.0, 0.0, 1.0),time)
	tween.tween_property(right,"modulate",Color(1.0, 1.0, 1.0, 1.0),time)

func back_effect(time=0.4)->void:
	var tween = create_tween().set_parallel().set_ease(Tween.EASE_IN_OUT)
	if time !=0:
		animated_sprite_2d.play_backwards("default")
	else :
		animated_sprite_2d.frame =0
	tween.tween_property(left,"modulate",Color(1.0, 1.0, 1.0, 1.0),time)
	tween.tween_property(right,"modulate",Color(0.0, 0.0, 0.0, 1.0),time)
