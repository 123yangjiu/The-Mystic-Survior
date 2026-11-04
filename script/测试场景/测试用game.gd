extends Node2D

func _ready() -> void:
	GameEvent.test()
	if GameEvent.is_start==false:
		start_game()

func start_game()->void:
	return
	GameEvent.start(true)
	GameEvent.paused=0
	GameEvent.difficulty=1
	GameEvent.the_first=0
	GameEvent.is_start=true
	GameEvent.is_co_disappear=false
	GameEvent.increase_percent = 1.0
	GameEvent.difficulty_timer.start()



func _input(event: InputEvent) -> void:
	pass
