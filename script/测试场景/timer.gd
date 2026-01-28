extends Timer
@onready var 实体: Node = $"../实体"




func _on_timeout() -> void:
	var number = 实体.get_child_count()-1
	GameEvent.current_monster=number
	print("当前难度：",GameEvent.difficulty)
	print("当前刷怪：",GameEvent.current_monster)
