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
var init_damage =15
var damage_range:=1.0

var init_scale:=Vector2(1.0,1.0)
var scale_range :=1.0

#var speed =20
#var speed_range :=1.0

#冷却，音量,基础位置，从自身节点获得的变量，勿在此改变
var init_position:=Vector2(0.0,1.0)

var base_wait_time:float
var wait_range :=1.0

var volume:=-6.0
var volume_range :=1.0

func _ready() -> void:
	base_wait_time=timer.wait_time
	if audio:
		volume=audio.volume_db
		audio.bus="Sound"
	init_position=self.position
	timer.timeout.connect(on_timer_timeoout)
	GameEvent.ability_upgrade_add.connect(on_ability_upgrade_add)
	set_variable()

func set_variable()->void:
	pass

func on_timer_timeoout():
	for i in number:
		attack()

func check_enemy()->Array[Node]:
	var enemies= get_tree().get_nodes_in_group("enemy")
	enemies=enemies.filter(func(enemy:Node2D):#过滤掉不在范围内的敌人
		return enemy.global_position.distance_squared_to(GameEvent.play_global_position)<pow(max_range,2)
	)
	#get_first_node_in_group是拿到组里面的第一个节点，如果我们想要拿到player节点
	#就要在player脚本中加入add_to_group("player")
	enemies.sort_custom(func (a:Node2D,b:Node2D):
		var A_distance=a.global_position.distance_squared_to(GameEvent.play_global_position)
		var B_distance=b.global_position.distance_squared_to(GameEvent.play_global_position)
		return A_distance< B_distance
	)
	return enemies

func before_attack_find_enemy(enemies:Array):
	#防止空数组
	if enemies.is_empty():
		return false
	#找到没被释放的敌人
	var n=0
	while enemies[n]==null:
		if n==enemies.size()-1:
			return false
		n+=1
	var enemy :Node2D= enemies[n]
	return enemy

func attack()->void:
	var ability_instance= ability.instantiate()
	var foreground = get_tree().get_first_node_in_group("前景图层")
	foreground.add_child(ability_instance)#加入到场景中
	if audio:
		audio.play()
	ability_instance.scale= init_scale*scale_range
	ability_instance.hitbox_component.damage =int(init_damage*damage_range+randf_range(-5,5))
	ability_instance.global_position = return_position()

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
