class_name DisappearComponent
extends EnemyComponent
@onready var timer: Timer = $Timer

@export var disappear_time:=20.0

func initial()->void:
	timer.wait_time=disappear_time


func _on_timer_timeout() -> void:
	owner.queue_free()
