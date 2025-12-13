extends Node
var MAX_RANGE=200
@export var hammer_ability:PackedScene

var Damage=25#定义的伤害
var base_wait_time#定义基础冷却
var base_scale=1#定义光剑基础大小
var volume :=-2

func _ready() -> void:
	base_wait_time=$Timer.wait_time
	$Timer.timeout.connect(on_timer_timeoout)
	GameEvent.ability_upgrade_add.connect(on_ability_upgrade_add)
	

func on_timer_timeoout():
	var player=get_tree().get_first_node_in_group("player") as Player
	var enemies= get_tree().get_nodes_in_group("enemy")
	enemies=enemies.filter(func(enemy:Node2D):#过滤掉不在范围内的敌人
		return enemy.global_position.distance_squared_to(player.global_position)<pow(MAX_RANGE,2)
	
	)
	#get_first_node_in_group是拿到组里面的第一个节点，如果我们想要拿到player节点
	#就要在player脚本中加入add_to_group("player")
	enemies.sort_custom(func (a:Node2D,b:Node2D):
		var A_distance=a.global_position.distance_squared_to(player.global_position)
		var B_distance=b.global_position.distance_squared_to(player.global_position)
		return A_distance< B_distance
	
		
	)
	
	
	var hammer_instance :Hammerability= hammer_ability.instantiate()
	var foreground = get_tree().get_first_node_in_group("前景图层")
	

		# ② 等节点_ready完成再赋值，避免 nil
	foreground.add_child(hammer_instance)#加入到场景中
	hammer_instance.huijian.volume_db=volume
	hammer_instance.huiji.volume_db=volume
	if ! player.animated_sprite_2d.flip_h:
		hammer_instance.scale.x *=-1
	hammer_instance.scale*=base_scale
	hammer_instance.hitbox_component.damage =int(Damage+randf_range(-5,5))
	if enemies.is_empty():
		hammer_instance.queue_free()
		return
		
		 # ③ 位置 & 朝向
	hammer_instance.global_position =player.global_position
		

# 再拿最近的那只
	

	
func on_ability_upgrade_add(upgrade:AbilityUpgrade,current_upgrade:Dictionary):

	#监听所有关于剑的升级
	print("解锁成功")
	if upgrade.ID=="光的速度":
		var persent_reduction=current_upgrade["光的速度"]["quantity"]*.2
		$Timer.wait_time=max(base_wait_time*(1-persent_reduction),1.15)
		volume =-2-6*persent_reduction
		$Timer.start()
	if upgrade.ID=="光的力量":
		Damage*=1.2
		print(Damage)
	if upgrade.ID=="解锁光剑":
		$Timer.start()
	if upgrade.ID=="光剑变大":
		base_scale+=0.2
		MAX_RANGE +=0.2*MAX_RANGE
		#print("解锁战锤")
		
	#pass	
