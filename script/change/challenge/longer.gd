extends ChangeButton

func set_check()->void:
	check_target=true

func get_check_object():
	return GameEvent.hard_mode[GameEvent.HARD_MODE.is_long] 

func target()->void:
	GameEvent.hard_mode[GameEvent.HARD_MODE.is_long]  = true

func back()->void:
	GameEvent.hard_mode[GameEvent.HARD_MODE.is_long]  = false
