extends Sprite2D

var is_drag := false  :set=set_is_drag# 记录拖拽状态
var touch_id := -1    # 记录当前控制摇杆的手指ID
@onready var yao_gan: Sprite2D = $YaoGan
@export var player: Player

# 存储所有活动触摸点
var active_touches := {}
var is_fixed:=false

func _ready() -> void:
	if GameEvent.is_fixed:
		is_fixed=true
		self.visible=true
		self.position=Vector2(102.0,267.0)
	GameEvent._paused.connect(_on_paused)

func _input(event: InputEvent) -> void:
	# 处理触摸开始
	if event is InputEventScreenTouch and event.is_pressed():
		_process_touch_start(event)
	# 处理触摸拖动 - 只有当这个触摸点控制摇杆时才处理
	elif event is InputEventScreenDrag:
		if event.index == touch_id:  # 只处理控制摇杆的手指
			_process_drag(event)
	# 处理触摸结束
	elif event is InputEventScreenTouch and event.is_released():
		_process_touch_end(event)

func _process_touch_start(event: InputEventScreenTouch) -> void:
	# 如果已经有手指在控制摇杆，并且这是第二根手指
	if is_drag and touch_id != -1:
		# 删除原来的摇杆（隐藏）
		self.visible = false
		is_drag = false
		if player:
			player.is_touch = false
		
		# 记录新手指的ID并生成新摇杆
		touch_id = event.index
		self.global_position = event.position
		self.visible = true
		is_drag = true
		
		# 重置摇杆位置
		yao_gan.position = Vector2.ZERO
		
		if player:
			player.is_touch = true
	
	# 如果还没有手指控制摇杆
	elif is_fixed:
		touch_id = event.index
		# 重置摇杆位置
		yao_gan.position = Vector2.ZERO
		if player:
			player.is_touch = true
	elif not is_drag:
		touch_id = event.index
		self.global_position = event.position
		self.visible = true
		is_drag = true
		
		# 重置摇杆位置
		yao_gan.position = Vector2.ZERO
		
		if player:
			player.is_touch = true

func _process_drag(event: InputEventScreenDrag) -> void:
	# 只处理控制摇杆的手指
	if event.index != touch_id:
		return
	
	var vector: Vector2 = (event.position - self.global_position) / 2
	if vector.length() > 22:  # 如果距离差大于两圆半径之差
		vector = vector.normalized() * 22
	
	yao_gan.position = vector
	
	if player:
		player.direction = vector.normalized()

func _process_touch_end(event: InputEventScreenTouch) -> void:
	# 如果松开的是控制摇杆的手指
	if is_fixed:
		if player:
			player.is_touch = false
		touch_id = -1
		yao_gan.position=Vector2.ZERO
	elif event.index == touch_id:
		if player:
			player.is_touch = false
		is_drag = false
		touch_id = -1
		self.visible = false

func _on_paused() -> void:
	if !is_fixed:
		self.visible = false
		is_drag = false
		touch_id = -1

func set_is_drag(value)->void:
	if is_fixed:
		return
	is_drag=value
