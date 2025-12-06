extends CanvasLayer
@export var game_time_manager:Node


@onready var label: Label = %Label

func _process(_delta: float) -> void:
	var time_elapse=game_time_manager.get_time_elaspsed()
	label.text=format_second(time_elapse)#传入剩余时间
func format_second(seconds:float):
	var minute=int(floor(seconds/60))
	var remaining_second=seconds-(minute*60)
	return str(minute)+":"+str("%02d"%int(floor(remaining_second)))
	
