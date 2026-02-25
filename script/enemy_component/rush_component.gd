class_name RushComponent
extends EnemyComponent

@export var collision_shape:CollisionShape2D
@onready var area_2d: Area2D = $Area2D

@onready var duration_timer: Timer = $RushDuration
@onready var interval_timer: Timer = $RushInterval
var velocity_component:VelocityController
var collision_component:CollisionComponent

@export_category("基础属性")
@export var rush_duration :=0.6
@export var rush_interval :=3.0
@export var rush_speed :=500.0

var ori_speed:float
var ori_acceleration:float
var ori_turn_rate:float
var player_in:=false

func initial()->void:
	duration_timer.wait_time=rush_duration
	interval_timer.wait_time=rush_interval
	var _owner = owner as Enemy
	if ! _owner.is_node_ready():
		await _owner.ready
	var ori_global_position = collision_shape.global_position
	remove_child(collision_shape)
	area_2d.add_child(collision_shape)
	collision_shape.global_position=ori_global_position
	for component in _owner.all_component:
		if component is VelocityController:
			velocity_component=component
		elif component is CollisionComponent:
			collision_component=component

func _on_rush_duration_timeout() -> void:
	pass_ori()
	collision_component.collision_shape_2d.disabled=false
	interval_timer.start()

func set_ori()->void:
	ori_speed=velocity_component.speed
	ori_acceleration=velocity_component.acceleration
	ori_turn_rate=velocity_component.turn_rate

func pass_ori()->void:
	if velocity_component.speed < ori_speed:
		return
	velocity_component.speed =ori_speed
	velocity_component.acceleration =ori_acceleration
	velocity_component.turn_rate=ori_turn_rate

func _on_rush_interval_timeout() -> void:
	if player_in:
		duration_timer.start()
		set_ori()
		collision_component.collision_shape_2d.disabled=true
		velocity_component.speed = rush_speed
		velocity_component.turn_rate =0
		velocity_component.acceleration *= rush_speed/ori_speed

func _on_area_2d_body_entered(body: Node2D) -> void:
	if ! body is Player or ! velocity_component:
		return
	#玩家进入
	player_in=true
	interval_timer.start()

func _on_area_2d_body_exited(body: Node2D) -> void:
	if ! body is Player:
		return
	player_in=false
