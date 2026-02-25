extends FlyAbilityController

func set_variable()->void:
	init_damage=12
	max_range=160
	number=1
	amount=100
	init_scale=Vector2(1.2,1.2)
	volume=-2

func while_attack(enemies:Array[Node])->void:
	#防止空数组
	if enemies.is_empty():
		return
	var real_number = int(number)
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

func set_plus(ability_instance:Sword,target_position)->void:
	ability_instance.global_position = target_position
	var dir_to_player =GameEvent.play_global_position - target_position
	ability_instance.rotation = -dir_to_player.angle()
	var collision_gap =ability_instance.end.global_position-ability_instance.global_position
	ability_instance.global_position-=collision_gap/3
	var db_value = volume+20 * log(volume_range) / log(10)
	db_value = clamp(db_value, -80, 6)
	ability_instance.audio_stream_player_2d.volume_db=db_value

func on_ability_upgrade_add(upgrade:AbilityUpgrade,_current_upgrade:Dictionary):
	#监听所有关于剑的升级
	if upgrade.ID=="剑的速度":
		set_speed(0.2)
	if upgrade.ID=="剑的伤害":
		damage_range*=1.3
	if upgrade.ID=="剑的数量":
		number+=1
		volume_range-=0.05
