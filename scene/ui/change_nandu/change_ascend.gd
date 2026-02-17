extends ChangeButton

func set_check()->void:
	check_target=true

func get_check_object():
	return GameEvent.easy_mode[GameEvent.EASY_MODE.is_ascend]

func target()->void:
	GameEvent.easy_mode[GameEvent.EASY_MODE.is_ascend] = true

func back()->void:
	GameEvent.easy_mode[GameEvent.EASY_MODE.is_ascend] = false
