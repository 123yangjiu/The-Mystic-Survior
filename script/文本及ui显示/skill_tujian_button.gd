extends Button


@export var skill:PackedScene

func _on_pressed() -> void:
	var skill_screen = skill.instantiate()
	add_child(skill_screen)
