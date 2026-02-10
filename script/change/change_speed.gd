extends ChangeButton

func set_check()->void:
	check_target=true

func get_check_object():
	return GameEvent.easy_mode.is_slow

func target()->void:
	GameEvent.easy_mode.is_slow = true

func back()->void:
	GameEvent.easy_mode.is_slow = false
