extends AgainstThing
class_name LightAbility
@onready var huijian: AudioStreamPlayer2D = $挥剑
@onready var huiji: AudioStreamPlayer2D = $汇集

func _ready() -> void:
	if ! GameEvent.play_right:
		scale.x =-1

func flip()->void:
	if ! GameEvent.play_right:
		scale.x =-1
	else :
		scale.x =1
