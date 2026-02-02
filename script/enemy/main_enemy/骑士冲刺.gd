class_name ChongCi
extends Area2D
@onready var velocity_component: Velocity_controller = $"../velocity_component"
@onready var hurtboxcomponent: HutboxComponent = $"../Hurtboxcomponent"

var can_rush := false
var rush_speed:=850

func _ready() -> void:
	body_entered.connect(on_body_enter)
	body_exited.connect(on_body_exited)
	$"../rush_duration".timeout.connect(end_rush)
	$"../rush_interval".timeout.connect(rush_again)

func on_body_enter(_area: Node2D) -> void:
	if not _area.is_in_group("player"): 
		return
	can_rush = true
	do_rush()
	$"../rush_interval".start()   # 启动 2 s 循环

func on_body_exited(_area: Node2D) -> void:
	if not _area.is_in_group("player"): return
	can_rush = false
	velocity_component.speed = 100
	velocity_component.acceleration = 7

func do_rush():
	velocity_component.speed = 850
	velocity_component.acceleration = 3
	$"../rush_duration".start()   # 1.8 s 后结束本次冲刺

func end_rush():
	velocity_component.speed = 100
	velocity_component.acceleration = 7

func rush_again():
	if can_rush:
		velocity_component.speed = 700
		velocity_component.acceleration =4
		$"../rush_duration".start()
		$"../rush_interval".start()
