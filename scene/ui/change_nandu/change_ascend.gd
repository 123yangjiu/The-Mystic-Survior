extends ChangeButton

func set_check()->void:
	check_target=true

func get_check_object():
	return GameEvent.easy_mode.is_ascend

func target()->void:
	GameEvent.easy_mode.is_ascend = true

func back()->void:
	GameEvent.easy_mode.is_ascend = false
