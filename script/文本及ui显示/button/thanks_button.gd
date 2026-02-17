extends Button

@export var thanks_list:PackedScene

func _on_pressed() -> void:
	var thanks_screen = thanks_list.instantiate()
	add_child(thanks_screen)
