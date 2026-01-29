extends Control
@onready var main_theme: AudioStreamPlayer = $MainTheme
@export var setting_screen:PackedScene
@export var brochure:PackedScene

func _ready() -> void:
	#AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"),-6)
	#AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Sound"),-6)
	#AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"),-6)
	await get_tree().create_timer(0.2).timeout
	main_theme.play()
	

func _on_开始_button_up() -> void:
	get_tree().paused= false
	GameEvent.difficulty=1
	GameEvent.the_first=0
	get_tree().change_scene_to_file("res://scene/game.tscn")
	GameEvent.difficulty_timer.start()
	queue_free()

func _on_离开_button_up() -> void:
	get_tree().quit()
	pass # Replace with function body.

func _on_setting_button_up() -> void:
	var _setting_screen = setting_screen.instantiate()
	add_child(_setting_screen)
	pass # Replace with function body.


func _on_brochure_button_down() -> void:
	var brochure_screen = brochure.instantiate()
	add_child(brochure_screen)
