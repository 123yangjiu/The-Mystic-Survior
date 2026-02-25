extends AgainstThing
@onready var huijian: AudioStreamPlayer2D = $挥剑
@onready var huiji: AudioStreamPlayer2D = $汇集

var is_follow:=true
var is_right:=false

func _ready() -> void:
	if ! GameEvent.play_right:
		scale.x =-abs(scale.x)
		is_right =false
	else :
		is_right=true

func _physics_process(_delta: float) -> void:
	if is_follow:
		global_position=GameEvent.play_global_position+Vector2(0.0,-21.0)

func flip()->void:
	var real_scale = scale.y
	scale.y=abs(scale.x)
	scale.x=real_scale
	is_follow=false
	if ! GameEvent.play_right:
		scale.x =- abs(scale.x)
		if is_right:
			scale.y *=-1
	else :
		scale.x =abs(scale.x)
		if ! is_right:
			scale.y *=-1
