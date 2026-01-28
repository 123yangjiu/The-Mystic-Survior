extends Timer
@onready var 实体: Node = $"../实体"




func _on_timeout() -> void:
	var number = 实体.get_children().size()-1
	GameEvent.current_monster=number
	print("现在难度：",GameEvent.difficulty)
	print("现在出怪量：",GameEvent.current_monster)
	pass # Replace with function body.
