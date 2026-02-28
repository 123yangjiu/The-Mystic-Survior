extends Node2D
class_name Game
@export var stop_screen:PackedScene

func _ready() -> void:
	start_game()

func start_game()->void:
	GameEvent.start(true)
	GameEvent.paused=0
	GameEvent.difficulty=1
	GameEvent.the_first=0
	GameEvent.is_start=true
	GameEvent.is_co_disappear=false
	GameEvent.difficulty_timer.start()



func _input(event: InputEvent) -> void:
	if event.is_action_released("暂停"):
		var screen=stop_screen.instantiate()
		add_child(screen)
