extends ChangeButton

func set_check()->void:
	check_target=true
	#设置信号
	if ! GameEvent.is_fixed:
		self.visible=false
	GameEvent.yaogan_fixed.connect(on_fixed)

func get_check_object():
	return GameEvent.fix_right

func target()->void:
	GameEvent.fix_right=true

func back()->void:
	GameEvent.fix_right=false

func on_fixed(value)->void:
	if value:
		self.visible=true
	else :
		visible = false
