extends Control
@onready var main_theme: AudioStreamPlayer = $MainTheme
@export var setting_screen:PackedScene

func _ready() -> void:
	GameEvent.is_start=false
	GameEvent.start(true)
	await get_tree().create_timer(0.2).timeout
	main_theme.play()

func _on_开始_button_up() -> void:
	get_tree().change_scene_to_file("res://scene/game.scn")
	queue_free()

func _on_离开_button_up() -> void:
	get_tree().quit()

func _on_setting_button_up() -> void:
	var _setting_screen = setting_screen.instantiate()
	add_child(_setting_screen)
