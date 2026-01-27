extends Sprite2D

@onready var texture_progress_bar: TextureProgressBar = $".."
#用来指示坐标的
@onready var begin: Node2D = $"../Anchor/Begin"
@onready var end: Node2D = $"../Anchor/End"
@onready var up: Node2D = $"../Anchor/Up"
@onready var down: Node2D = $"../Anchor/Down"
@onready var label: Label = $"../Label"

var is_drag:=false
var ready_position_x:float :set=set_current_position
var is_ready:=false
@export var bus_name:String
func _ready() -> void:
	if bus_name=="Sound" and GameEvent.sound_db:
		ready_position_x = GameEvent.sound_db
	elif  bus_name =="Master" and GameEvent.master_db:
		ready_position_x = GameEvent.master_db
	elif bus_name=="Music" and GameEvent.music_db:
		ready_position_x = GameEvent.music_db


func _input(event: InputEvent) -> void:
	if !is_ready:
		return
	var _position = event.position#检测鼠标是不是在检测范围内点击的
	if event is InputEventScreenTouch and event.is_pressed():
		_process_touch(event)
	elif is_drag:
		if event is InputEventScreenDrag:
			_process_drag(event)
		elif  event is InputEventScreenTouch and event.is_released():
			_process_released(event)


func _process_touch(event:InputEvent)->void:
	if is_drag:
		return
	ready_position_x=event.position.x
	is_drag=true

func _process_drag(event:InputEvent)->void:
	ready_position_x=event.position.x

func _process_released(_event:InputEvent)->void:
	is_drag=false

func set_current_position(value):
	var min_position_x = begin.global_position.x
	var max_position_x = end.global_position.x
	ready_position_x = max(min_position_x,value)
	ready_position_x=min(max_position_x,ready_position_x)
	var percent = (ready_position_x-min_position_x)/(max_position_x-min_position_x)
	texture_progress_bar.value = percent*100
	label.modulate=Color.from_hsv(0.0, 0.0, percent, 1.0)
	#想调哪个音频总线调这里
	var db_value = 6+20 * log(percent) / log(10)
	# 限制在 -80 到 6 dB 之间
	db_value = clamp(db_value, -80, 6)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(bus_name),db_value)
	self.global_position.x=ready_position_x
	GameEvent.record_db(bus_name,value)
	
