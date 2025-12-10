extends CanvasLayer

func _ready() -> void:
	get_tree().paused = true
	%restart.pressed.connect(on_restart_press)
	%quit.pressed.connect(on_quit_press)


func on_restart_press():
	get_tree().paused= false
	GameEvent.difficulty=1
	GameEvent.the_first=0
	get_tree().change_scene_to_file("res://scene/game.tscn")
	GameEvent.difficulty_timer.start()
	pass
func  on_quit_press():
	get_tree().quit()
	pass
