extends AbilityController
class_name FlyAbilityController

var speed =20
var speed_range :=1.0

var enemy_position:Vector2

func check_enemy()->Array[Node]:
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

func while_attack(enemies:Array[Node])->void:
	var real_number = int(number)
	if number_range!=1.0:
		real_number=int(number*number_range)+1
	for i in range(real_number):
		#找到敌人，并排除各种问题
		var enemy = before_attack_find_enemy(enemies)
		if enemy:
			enemy_position = enemy.global_position
			attack()
		else:
			return

func before_attack_find_enemy(enemies:Array[Node]):
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

func return_position():
	return enemy_position
