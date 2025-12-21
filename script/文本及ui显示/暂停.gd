extends CanvasLayer

var can_free :=false


func _ready() -> void:
	get_tree().paused = true
	GameEvent.paused+=1
	await get_tree().create_timer(0.3).timeout
	can_free=true
	

func _input(event: InputEvent) -> void:
	if can_free:
		if event.is_action_pressed("暂停"):
			if GameEvent.paused>0:
				GameEvent.paused-=1
				if GameEvent.paused==0:
					get_tree().paused=false
			get_viewport().set_input_as_handled()
			GameEvent.stop_end.emit()
			queue_free()
