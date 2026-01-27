extends TextureProgressBar
@onready var button: Sprite2D = $Button




func _on_mouse_entered() -> void:
	button.is_ready =true
	pass # Replace with function body.


func _on_mouse_exited() -> void:
	button.is_ready =false
	pass # Replace with function body.
