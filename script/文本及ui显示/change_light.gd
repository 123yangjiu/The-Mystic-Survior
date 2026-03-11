extends ChangeButton

func set_check()->void:
	check_target=false

func get_check_object():
	return GameEvent.is_light_auto

func target()->void:
	GameEvent.is_light_auto=false

func back()->void:
	GameEvent.is_light_auto=true
