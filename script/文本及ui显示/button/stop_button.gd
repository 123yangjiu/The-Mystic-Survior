extends TextureButton

@export var setting_screen:PackedScene

func _on_pressed() -> void:
	var screen = setting_screen.instantiate()
	add_child(screen)
