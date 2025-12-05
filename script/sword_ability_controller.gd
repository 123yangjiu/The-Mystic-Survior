extends  Node
const MAX_RANGE=150
@export var sword_ability:PackedScene

var Damage=12#定义剑的伤害
var base_wait_time#定义基础冷却
var number=1#定义基础剑的数量

func _ready() -> void:
	base_wait_time=$Timer.wait_time
	get_node("Timer").timeout.connect(on_timer_timeoout)
	print(GameEvent.ability_upgrade_add.connect(on_ability_upgrade_add))
	
func on_timer_timeoout():
	var player=get_tree().get_first_node_in_group("player") as Node2D
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
	#print("过滤+排序后敌人数量=", enemies.size())
	var spawn_number=min(enemies.size(),number)
	if spawn_number==0:
		return
	for i in range(spawn_number):
		var sword_instance = sword_ability.instantiate() as Swordability
		var foreground = get_tree().get_first_node_in_group("前景图层")

		# ② 等节点_ready完成再赋值，避免 nil
		foreground.add_child(sword_instance)
		sword_instance.hitbox_component.damage = int(Damage+randf_range(-2,4))
		if enemies.is_empty():
			sword_instance.queue_free()
			return

		var enemy = enemies[i]
		

		# ③ 位置 & 朝向
		sword_instance.global_position =enemy.global_position
		sword_instance.global_position += Vector2.RIGHT.rotated(randf_range(0, TAU)) * 4
		var dir_to_player = player.global_position - enemy.global_position
		sword_instance.rotation = dir_to_player.angle()
	

# 再拿最近的那只
	

	
func on_ability_upgrade_add(upgrade:AbilityUpgrade,current_upgrade:Dictionary):
	print("saiuofai")
	#监听所有关于剑的升级
	if upgrade.ID=="剑的速度":
		var persent_reduction=current_upgrade["剑的速度"]["quantity"]*.2
		$Timer.wait_time=max(base_wait_time*(1-persent_reduction),0.1)
		$Timer.start()
	if upgrade.ID=="剑的伤害":
		var persent_improvement=current_upgrade["剑的伤害"]["quantity"]*.3
		Damage=Damage*(1+persent_improvement)
		print(Damage)
	if upgrade.ID=="剑的数量":
		number+=1
	pass	
	
	
