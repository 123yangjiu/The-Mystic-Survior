extends AK47AbilityController

#爆炸范围
var check_range :=100.0
var expolotion_damage :=50

func set_variable()->void:
	#射程，子弹数量，射击间隔，转头间隔，位置
	max_range=125
	number = 1
	fire_interval=0.8
	turn_interval =0.05
	init_position=Vector2(-10.0,-6.0)
	recoil_po =return_randf(1,2,false)
	recoil_ro_degrees=return_randf(-20,-40,false)
	#伤害，大小,速度
	init_damage = 15
	init_scale=Vector2(1.0,1.0)
	speed =8

func check_enemy()->Array[Node]:
	var enemies:Array[Node]= get_tree().get_first_node_in_group("enemylayer").get_children()
	enemies=enemies.filter(func(enemy:Node2D):#过滤掉不在范围内的敌人
		return enemy.global_position.distance_squared_to(GameEvent.play_global_position)<pow(260,2) 
	)
	#get_first_node_in_group是拿到组里面的第一个节点，如果我们想要拿到player节点
	#找到聚堆的小怪群
	var enemies_clone := enemies.duplicate(true)
	enemies.sort_custom(func (a:Node2D,b:Node2D):
		var a_global_position := a.global_position
		var b_global_position := b.global_position
		var A:=0
		var B:=0
		for another_enemy in enemies_clone:
			if another_enemy.global_position.distance_squared_to(a_global_position)<pow(check_range,2):
				A+=1
			if another_enemy.global_position.distance_squared_to(b_global_position)<pow(check_range,2):
				B+=1
		return A>B
	)
	return enemies

func turnto_enemy(enemy_global_position:Vector2)->void:
	#var abiility_instance = ability.instantiate()
	#add_child(abiility_instance)
	#abiility_instance.position = zidan.position
	var direction =(enemy_global_position-zidan.global_position).normalized()
	var tween = get_tree().create_tween()
	tween.tween_property(self,"rotation",direction.angle(),turn_interval)
	#使用协程
	await tween.finished

func attack(enemy_global_position:Vector2)->void:
	#找到落脚点
	var foreground = get_tree().get_first_node_in_group("前景图层")
	#生成子弹,并发出枪声
	var ability_instance = ability.instantiate() as Rocket
	foreground.add_child(ability_instance)
	audio.play()
	#设置基本属性
	#ability_instance.scale = init_scale*scale_range
	ability_instance.attack_component.damage = init_damage*damage_range
	ability_instance.attack_component_2.damage = expolotion_damage*damage_range
	ability_instance.attack_component_2.scale = init_scale*number_range
	ability_instance.global_position=zidan.global_position
	ability_instance.direction=(enemy_global_position-zidan.global_position).normalized()
	ability_instance.rotation = ability_instance.direction.angle()
	ability_instance.speed =speed
	ability_instance.amount=100
	ability_instance.dir_enemy_global_position=enemy_global_position

func while_attack(enemies:Array[Node])->void:
	var real_number = int(number)
	for i in range(real_number):
		#找到敌人，并排除各种问题
		var enemy = before_attack_find_enemy(enemies)
		if enemy:
			var enemy_global_position = enemy.global_position
			#将枪头对准enemy,再攻击
			await turnto_enemy(enemy_global_position)
			attack(enemy_global_position)
			#触发后坐力
			await after_attack(enemy_global_position)
		else:
			return
		#检测弹药
		if current_number<=0:
			start_reload()
			return

func end_reload()->void:
	zidan_number.visible=true
	rotation =fmod(fmod(rotation, TAU) + TAU, TAU)
	current_number=number
	_continue.stop()
	audio.stop()
	change_bullet_1.stop()
	change_bullet_2.stop()
