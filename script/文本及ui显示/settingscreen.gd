extends CanvasLayer


func _on_button_button_up() -> void:
	GameEvent.start(true)
	self.queue_free()

func _input(event: InputEvent) -> void:
	if event.is_action_released("暂停"):
		get_viewport().set_input_as_handled()
		GameEvent.start(true)
		self.queue_free()
