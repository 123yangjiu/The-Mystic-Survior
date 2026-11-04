class_name VirtualThumbstick
extends Sprite2D

var is_drag := false  :set=set_is_drag# 记录拖拽状态
var touch_id := -1    # 记录当前控制摇杆的手指ID
@onready var yao_gan: Sprite2D = $YaoGan
@export var player: Player

# 存储所有活动触摸点
var active_touches := {}
var is_fixed:=false

#计算混乱状态
var key_to_vector:Dictionary[String,Vector2]={
	"up":Vector2(0,1),
	"down":Vector2(0,-1),
	"left":Vector2(-1,0),
	"right":Vector2(1,0)
	
}

func _ready() -> void:
	if GameEvent.is_fixed:
		is_fixed=true
		self.visible=true
		if GameEvent.fix_right:
			self.position=Vector2(540.0,267.0)
		else :
			self.position=Vector2(102.0,267.0)
	GameEvent.yaogan_fixed.connect(on_fix_change)
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
	var new_vector = get_right_vector(vector)
	yao_gan.position = vector
	
	if player:
		player.direction = new_vector.normalized()

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

func on_fix_change(fixed:bool)->void:
	match is_fixed:
		true:
			match fixed:
				false:
					is_fixed=false
					self.visible=false
				true:
					if GameEvent.fix_right:
						self.position=Vector2(540.0,267.0)
					else :
						self.position=Vector2(102.0,267.0)
		false:
			match fixed:
				true:
					is_fixed=true
					self.visible=true
					if GameEvent.fix_right:
						self.position=Vector2(540.0,267.0)
					else :
						self.position=Vector2(102.0,267.0)

func get_right_vector(vector:Vector2)->Vector2:
	var new_vector:=Vector2(0,0)
	if vector.x >=0:
		new_vector += vector.x * key_to_vector.get("right",Vector2(1,0))
	else :
		new_vector += -vector.x * key_to_vector.get("left",Vector2(-1,0))
	if vector.y >=0:
		new_vector += vector.y * key_to_vector.get("up",Vector2(0,1))
	else :
		new_vector += -vector.y * key_to_vector.get("down",Vector2(0,-1))
	return new_vector
