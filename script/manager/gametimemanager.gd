extends Node
@export var victory_screen:PackedScene

@onready var timer: Timer = $Timer
#@onready var difficulty_timer: Timer = $difficulty_timer
signal the_second_music#启动第二个音乐
var one_shot:=false

func _ready() -> void:
    timer.timeout.connect(on_timer_timeout)
func get_time_elaspsed():
    var time= timer.wait_time-timer.time_left
    if one_shot==false and time>=175.0:
        one_shot=true
        the_second_music.emit()
    return timer.wait_time-timer.time_left
func on_timer_timeout():
    var victory_screen_instance=victory_screen.instantiate()
    add_child(victory_screen_instance)
