extends Button


@export var tujian:PackedScene


func _on_pressed() -> void:
	var tujian_screen = tujian.instantiate()
	add_child(tujian_screen)
