extends Node

#节点
@export var ability:PackedScene
@export var timer:Timer
@export var audio:AudioStreamPlayer
#最大攻击范围，基础伤害，基础冷却，基础大小,基础音量
var max_range
var damage
var wait_time
var _scale
var volume
#基础数量，基础速度
var number
var speed


func _ready() -> void:
	wait_time = timer.wait_time
	volume=audio.volume_db
	timer.timeout.connect(on_time_out)
	GameEvent.ability_upgrade_add.connect(on_ability_upgrade_add)
func on_ability_upgrade_add(upgrade:AbilityUpgrade,current_upgrade:Dictionary):
	if upgrade.ID=="":
		pass
	if upgrade.ID=="":
		pass
	if upgrade.ID=="":
		pass
	if upgrade.ID=="解锁":
		timer.start()

func on_time_out()->void:
	audio.stop()
	await get_tree().create_timer(1).timeout
	var enemies=check_enemy()
	while_attack(enemies)

func check_enemy()->Array:
	var enemies:Array[Node]= get_tree().get_first_node_in_group("enemylayer").get_children()
	enemies=enemies.filter(func(enemy:Node2D):#过滤掉不在范围内的敌人
		return enemy.global_position.distance_squared_to(GameEvent.play_global_position)<pow(260,2) 
	)
	#get_first_node_in_group是拿到组里面的第一个节点，如果我们想要拿到player节点
	#就要在player脚本中加入add_to_group("player")
	enemies.sort_custom(func (a:Node2D,b:Node2D):
		var A_distance=a.global_position.distance_squared_to(GameEvent.play_global_position)
		var B_distance=b.global_position.distance_squared_to(GameEvent.play_global_position)
		return A_distance< B_distance
	)
	return enemies

func attack(enemy:Node2D)->void:
	var ability_instance = ability.instantiate() as FlyThing
	var foreground = get_tree().get_first_node_in_group("前景图层")
	ability_instance.scale = _scale
	# ② 等节点_ready完成再赋值，避免 nil
	foreground.add_child(ability_instance)
	#发出声音
	audio.volume_db=volume
	audio.play()
	ability_instance.hitbox_component.damage = int(damage+randf_range(-3,3))
	# ③ 位置 & 朝向

func while_attack(enemies:Array[Node])->void:
	if enemies.is_empty():
		return
	var n=0
	for i in range(number):
		while enemies[n]==null:
			if n==enemies.size()-1:
				return
			n+=1
		var enemy = enemies[n]
		attack(enemy)
