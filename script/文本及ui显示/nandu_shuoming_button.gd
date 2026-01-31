extends Button


@export var nandu:PackedScene

func _on_pressed() -> void:
	var nandu_screen = nandu.instantiate()
	add_child(nandu_screen)
