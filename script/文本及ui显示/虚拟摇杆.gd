extends Sprite2D

var is_drag:=false #记录拖拽状态
@onready var yao_gan: Sprite2D = $YaoGan
@export var player:Player

func _ready() -> void:
	GameEvent._paused.connect(_on_paused)

func _input(event: InputEvent) -> void:
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
	self.position= event.position
	if player:
		player.is_touch=true
	visible=true
	is_drag=true

func _process_drag(event:InputEvent)->void:
	var vector:Vector2= (event.position-self.global_position)/2
	if vector.length()>22: #如果距离差大于两圆半径之差
		vector= vector.normalized() *22
	yao_gan.position= vector
	if player:
		player.direction=vector.normalized()

func _process_released(_event:InputEvent)->void:
	if player:
		player.is_touch=false
	is_drag=false
	self.visible=false

func _on_paused()->void:
	self.visible=false
