extends Timer


@onready var enemy: Node = $"../enemy"


func _on_timeout() -> void:
	return
	var number = enemy.get_child_count()
	GameEvent.current_monster=number
