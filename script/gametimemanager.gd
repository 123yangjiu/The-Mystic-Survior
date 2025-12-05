extends Node
@export var victory_screen:PackedScene

@onready var timer: Timer = $Timer
#@onready var difficulty_timer: Timer = $difficulty_timer

func _ready() -> void:
	timer.timeout.connect(on_timer_timeout)
func get_time_elaspsed():
	return timer.wait_time-timer.time_left
func on_timer_timeout():
	var victory_screen_instance=victory_screen.instantiate()
	add_child(victory_screen_instance)

	
