extends  FlyAbilityController

var color_A:=255.0

func set_variable()->void:
	#射程，数量，穿透数量
	max_range=250
	number = 1
	amount=4
	#伤害，大小,速度
	init_damage =16.0
	init_scale=Vector2(0.9,0.9)
	speed =4

func while_attack(enemies:Array[Node])->void:
	#防止空数组
	if enemies.is_empty():
		return
	var real_number = int(number)
	if number_range!=1.0:
		real_number=int(number*number_range)+1
	for i in range(real_number):
		#找到敌人，并排除各种问题
			#找到没被释放的敌人
		var n=0
		if n+i<=enemies.size()-1:
			while enemies[n+i]==null:
				if n+i==enemies.size()-1:
					break
				n+=1
		else :
			n=enemies.size()-1-i
		var enemy :Node2D= enemies[n+i]
		if enemy:
			var enemy_position = enemy.global_position
			attack(enemy_position)
		else:
			return

func on_ability_upgrade_add(upgrade:AbilityUpgrade,_current_upgrade:Dictionary):
	if upgrade.ID=="火球力穿":
		amount+=3
		damage_range*=1.2
	if upgrade.ID=="火球大速":
		scale_range *=1.2
		set_speed(0.2)
	if upgrade.ID=="火球数量":
		number+=1
		color_A -=20 
	if upgrade.ID=="解锁火球":
		timer.start()

func set_plus(ability_instance,target_position)->void:
	ability_instance.rotation = ability_instance.direction.angle() -deg_to_rad(90)
	ability_instance.modulate.a8 =color_A /scale_range
	if (target_position-GameEvent.play_global_position).length_squared() >17000:
		ability_instance.speed =speed*speed_range*3
	else :
		ability_instance.speed =speed*speed_range
