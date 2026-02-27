extends ChangeButton

func set_check()->void:
	check_target=true

func get_check_object():
	return GameEvent.hard_mode[GameEvent.HARD_MODE.is_max_4] 

func target()->void:
	GameEvent.hard_mode[GameEvent.HARD_MODE.is_max_4]  = true

func back()->void:
	GameEvent.hard_mode[GameEvent.HARD_MODE.is_max_4]  = false
