class_name FlyThing
extends Node2D

#起始方向和速度
var direction:=Vector2(1.0,1.0)
var speed =5
#穿透数量和伤害
var amount :=1
#var damage :=5.0
@export var attack_component:AttackComponent
@export var timer:Timer

func _ready() -> void:
	attack_component.area_2d.area_entered.connect(on_area_enter)
	if timer:
		timer.timeout.connect(on_timer_out)

func on_area_enter(area:Area2D):
	if ! area is AreaInComponent:
		return
	var _area = area as AreaInComponent
	var component := _area.return_component()
	if ! component is WoundComponent:
		return
	amount-=1
	if amount==0:
		queue_free()

func _physics_process(_delta: float) -> void:
	global_position+=direction*speed

func on_timer_out()->void:
	queue_free()
