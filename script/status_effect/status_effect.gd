extends Node
class_name StatusEffect

@export var duration: float = 5.0
var _timer: Timer

func listen(target: Node):
	for child in target.get_children():
		if child.get_script() == get_script():
			child._refresh()
			return
	var instance = duplicate()
	instance._start_timer()
	target.add_child(instance)

func _start_timer():
	_timer = Timer.new()
	_timer.one_shot = true
	_timer.timeout.connect(_on_expire)
	add_child(_timer)
	_timer.start(duration)

func _refresh():
	_timer.start(duration)

func _on_expire():
	queue_free()
