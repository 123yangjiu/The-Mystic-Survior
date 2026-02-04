extends TextureButton

@export var setting_screen:PackedScene

func _on_pressed() -> void:
	stop_game()
func stop_game()->void:
	GameEvent.paused+=1
	get_tree().paused=true
	GameEvent.game_stop.emit()
	var screen=setting_screen.instantiate()
	add_child(screen)
