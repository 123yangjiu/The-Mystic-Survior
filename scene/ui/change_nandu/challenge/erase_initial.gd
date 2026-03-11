extends ChangeButton

func set_check()->void:
	check_target=true

func get_check_object():
	return GameEvent.hard_mode[GameEvent.HARD_MODE.is_erase_ability] 

func target()->void:
	GameEvent.hard_mode[GameEvent.HARD_MODE.is_erase_ability]  = true

func back()->void:
	GameEvent.hard_mode[GameEvent.HARD_MODE.is_erase_ability]  = false
