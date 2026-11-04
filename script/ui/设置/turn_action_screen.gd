extends Button

@export var screen:PackedScene

func _on_pressed() -> void:
	var screen_institate = screen.instantiate()
	add_child(screen_institate)
