extends Control
@onready var main_theme: AudioStreamPlayer = $MainTheme

func _ready() -> void:
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
