extends Timer


@onready var enemy: Node = $"../enemy"


func _on_timeout() -> void:
	var number = enemy.get_child_count()
	GameEvent.current_monster=number
