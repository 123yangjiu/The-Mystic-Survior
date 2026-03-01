extends EnemyComponent
class_name VelocityController
@export var speed:float=0.0 :set=set_speed
@export var acceleration:float=5
@export var turn_rate:= 5.0   # 转向速度

var need_direction_node:Node2D
var is_initial:=true
var velocity=Vector2.ZERO

func initial()->void:
	set_other()

func _physics_process(_delta: float) -> void:
	var _owner = owner as Enemy
	accelerate_to_direction()
	move(_owner)
	if velocity.x<0:
		_owner.animated_sprite_2d.flip_h =true
	if velocity.x>0:
		_owner.animated_sprite_2d.flip_h =false

func set_other()->void:
	pass

func accelerate_to_direction():
	var direction = get_direction()
	var delta =get_physics_process_delta_time()
	var current_dir :Vector2= velocity.normalized() if velocity.length() > 0 else Vector2.RIGHT
	if is_initial:
		is_initial=false
		current_dir =direction
	var turn_weight = 1.0 - exp(-turn_rate * delta)
	var new_dir = current_dir.lerp(direction, turn_weight).normalized()
	
	# 再处理速度大小
	var target_speed = speed
	var current_speed = velocity.length()
	
	# 速度插值
	var speed_weight = 1.0 - exp(-acceleration * delta)
	var new_speed = lerp(current_speed, target_speed, speed_weight)
	
	# 组合
	velocity = new_dir * new_speed

func get_direction()->Vector2:
	var direction:=get_player_direction()
	return direction

func get_player_direction()->Vector2:
	var owner_2D=owner as Node2D
	var direction:Vector2=(GameEvent.play_global_position-owner_2D.global_position).normalized()
	return direction

func move(character:Enemy):
	# 1. 用模块里“方向 * 速度”作为本次期望速度
	var desired_vel = velocity
	# 2. 交给物理处理碰撞、滑动
	character.velocity = desired_vel
	character.move_and_slide()
	if character.velocity.length() > speed*2.0:
		character.velocity = character.velocity.normalized()*speed*1.5 

func set_speed(value)->void:
	match GameEvent.mode_index:
		0:
			var new_speed = value
			if GameEvent.easy_mode[GameEvent.EASY_MODE.is_slow] == true:
				new_speed = value*0.9
			speed = new_speed
		2,3:
			var new_speed = value*1.1
			speed = new_speed
		_:
			speed=value
