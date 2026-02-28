extends Button


@export var brochure:PackedScene

func _on_pressed() -> void:
	var brochure_screen = brochure.instantiate()
	add_child(brochure_screen)
