extends CanvasLayer



func _on_button_button_up() -> void:
	if GameEvent.paused>=1:
		GameEvent.paused-=1
		GameEvent.stop_end.emit()
		if GameEvent.paused==0:
			get_tree().paused=false
	self.queue_free()

func _input(event: InputEvent) -> void:
	if event.is_action_released("暂停"):
		get_viewport().set_input_as_handled()
		if GameEvent.paused>=1:
			GameEvent.paused-=1
			GameEvent.stop_end.emit()
			if GameEvent.paused==0:
				get_tree().paused=false
		self.queue_free()
