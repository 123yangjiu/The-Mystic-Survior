extends Node
class_name StatusEffect

@export var duration: float = 5.0
var _timer: Timer

var carrier:Node

func attach_effect(target:Node,time:float)->void:
	for child in target.get_children():
		if child.get_script() == get_script():
			child._refresh()
			return
	duration=time
	carrier = target
	target.add_child(self)
	_start_timer()
	single_effect()
	cycle_effect()

func _refresh():
	if ! _timer:
		return
	_timer.start(duration)

#计算持续时间
func _start_timer():
	_timer = Timer.new()
	_timer.one_shot = true
	_timer.timeout.connect(_on_expire)
	add_child(_timer)
	_timer.start(duration)

func single_effect()->void:
	pass

func cycle_effect()->void:
	pass

func recover_effect()->void:
	pass

func _on_expire():
	recover_effect()
	queue_free()

func _exit_tree() -> void:
	pass
