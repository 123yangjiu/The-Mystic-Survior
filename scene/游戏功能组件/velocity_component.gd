extends Node
class_name Velocity_controller
@export var speed:int=40
@export var acceleration:float=5
var velocity=Vector2.ZERO
func accelerate_to_player():
	var owner_2D=owner as Node2D
	var player=get_tree().get_first_node_in_group("player")
	if !player:
		return
	var direction=(player.global_position-owner_2D.global_position).normalized()
	accelerate_to_direction(direction)
func accelerate_to_direction(direction:Vector2):
	var desired_velocity=direction*speed
	velocity=velocity.lerp(desired_velocity,1-exp(-acceleration*get_process_delta_time()))
func move(character: CharacterBody2D):
	# 1. 用模块里“方向 * 速度”作为本次期望速度
	var desired_vel = velocity
	# 2. 交给物理处理碰撞、滑动
	character.velocity = desired_vel
	character.move_and_slide()

	# 3. 🔥 只保留“沿输入方向”的分量，丢弃反弹/摩擦造成的额外速度
	var input_dir = desired_vel.normalized()
	var kept_speed = character.velocity.dot(input_dir)
	velocity = input_dir * kept_speed
	var max_slide = speed * 1.27
	if velocity.length() > max_slide:
		velocity = velocity.normalized() * max_slide
