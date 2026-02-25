class_name AbilityController
extends Node2D

@export var ability:PackedScene
@export var timer:Timer
@export var audio:AudioStreamPlayer2D

#最大攻击检测范围,基础数量
var max_range=200

var number = 1
var number_range :=1.0

#伤害，大小,速度
var init_damage :=15.0
var damage_range:=1.0

var init_scale:=Vector2(1.0,1.0)
var scale_range :=1.0 


#冷却，音量,基础位置，从自身节点获得的变量，勿在此改变
var init_position:=Vector2(0.0,1.0)

var base_wait_time:float
var wait_range :=1.0 :set= set_wait_range

var volume:=-6.0
var volume_range :=1.0

func _ready() -> void:
	base_wait_time=timer.wait_time
	if audio:
		volume=audio.volume_db
		audio.bus="Sound"
	init_position=self.position
	timer.timeout.connect(on_timer_timeout)
	GameEvent.ability_upgrade_add.connect(on_ability_upgrade_add)
	set_variable()

func set_variable()->void:
	pass

func on_timer_timeout():
	var real_number = int(number)
	if number_range!=1.0:
		real_number=int(number*number_range)+1
	for i in real_number:
		var target = return_position()
		attack(target)

func attack(_target_position)->void:
	var ability_instance= ability.instantiate()
	var foreground = get_tree().get_first_node_in_group("前景图层")
	foreground.add_child(ability_instance)#加入到场景中
	set_base(ability_instance,_target_position)
	set_plus(ability_instance,_target_position)

func set_base(instance,_target_position:Vector2)->void:
	if audio:
		audio.play()
	instance.scale= init_scale*scale_range
	instance.attack_component.damage = init_damage*damage_range
	instance.global_position = return_position()

func set_plus(_ability_instance,_target_position)->void:
	pass

func return_position():
	return GameEvent.play_global_position

func on_ability_upgrade_add(upgrade:AbilityUpgrade,current_upgrade:Dictionary):
	if upgrade.ID=="速度":
		var persent_reduction=current_upgrade["光的速度"]["quantity"]*.2
		$Timer.wait_time=max(base_wait_time*(1-persent_reduction),1.15)
		volume =-2-6*persent_reduction
		$Timer.start()
	if upgrade.ID=="力量":
		damage_range*=1.2
	if upgrade.ID=="解锁":
		$Timer.start()
	if upgrade.ID=="":
		scale_range*=1.2

func set_wait_range(value)->void:
	wait_range=value

func set_speed(gap_range)->void:
	wait_range-=gap_range
	volume_range-=0.05
	var db_value = volume+20 * log(volume_range) / log(10)
	db_value = clamp(db_value, -80, 6)
	if audio:
		audio.volume_db = db_value
	timer.wait_time = max(base_wait_time*wait_range,wait_range*0.1)
