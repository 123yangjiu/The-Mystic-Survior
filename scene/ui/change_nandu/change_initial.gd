extends ChangeButton

@export var skill:PackedScene

func get_check_object():
	return GameEvent.easy_mode.is_initial
func _on_button_up() -> void:
	var screen = get_check_object()
	if !screen:
		taeget_effect()
		target()
	else:
		back_effect()
		back()
func target()->void:
	var skill_screen = skill.instantiate()
	add_child(skill_screen)

func back()->void:
	GameEvent.easy_mode.is_initial=false

func to_initial()->void:
	self.button_up.connect(_on_button_up)
	if get_check_object():
		taeget_effect(0)
	else :
		back()
		back_effect(0)
