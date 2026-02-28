extends CanvasLayer

func _ready() -> void:
	if GameEvent.is_start:
		GameEvent.stop_game(true)

func _on_button_button_up() -> void:
	if GameEvent.is_start:
		GameEvent.start(true)
	self.queue_free()

func _input(event: InputEvent) -> void:
	if event.is_action_released("暂停"):
		if GameEvent.is_start:
			get_viewport().set_input_as_handled()
			GameEvent.start(true)
		self.queue_free()
