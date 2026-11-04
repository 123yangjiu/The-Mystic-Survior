class_name ExitButton
extends Button

@export var root_node:Node

func _on_pressed() -> void:
	root_node.queue_free()
