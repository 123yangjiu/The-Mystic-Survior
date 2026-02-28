extends ChangeButton

func set_check()->void:
	check_target=true

func get_check_object():
	return GameEvent.is_fixed

func target()->void:
	GameEvent.is_fixed=true

func back()->void:
	GameEvent.is_fixed=false
