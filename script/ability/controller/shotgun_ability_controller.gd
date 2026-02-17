extends AK47AbilityController

var check_range :=100.0
var bullet_number:=10.0
var max_angle :=PI/6

func _ready() -> void:
	#射程，子弹数量，射击间隔，转头间隔，位置
	max_range=80
	number = 2
	fire_interval=0.15
	turn_interval =0.05
	init_position=Vector2(9.0,6.0)
	recoil_po =return_randf(0.3,0.5,false)
	recoil_ro_degrees=return_randf(-20,-20)
	#伤害，大小,速度
	init_damage =10
	init_scale=Vector2(2.0,1.5)
	speed =15
	#基础参数
	base_wait_time=reload.wait_time
	volume=audio.volume_db
	change_1_pitch = change_bullet_1.pitch_scale
	change_2_pitch = change_bullet_2.pitch_scale
	init_position=self.position
	#连接参数
	reload.timeout.connect(on_reload_out)
	_continue.timeout.connect(on_reload_out)
	GameEvent.ability_upgrade_add.connect(on_ability_upgrade_add)
	var player = get_tree().get_first_node_in_group("实体图层").get_child(0)
	remove_child(zidan_number)
	player.add_child.call_deferred(zidan_number)
	zidan_number.position=Vector2(-20.0,-40.0)
	on_reload_out()

func while_attack(enemies:Array[Node])->void:
	for i in range(number):
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

func check_enemy()->Array[Node]:
	var enemies:Array[Node]= get_tree().get_first_node_in_group("enemylayer").get_children()
	enemies=enemies.filter(func(enemy:Node2D):#过滤掉不在范围内的敌人
		return enemy.global_position.distance_squared_to(GameEvent.play_global_position)<pow(260,2) 
	)
	#get_first_node_in_group是拿到组里面的第一个节点，如果我们想要拿到player节点
	#找到聚堆的小怪群
	var enemies_clone := enemies.duplicate()
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

func attack(enemy_global_position)->void:
	#找到落脚点
	var foreground = get_tree().get_first_node_in_group("前景图层")
	#计算子弹数和生成角度范围
	var real_bullet = int(bullet_number*number_range)+1
	var this_angle =float(max_angle)/(bullet_number*number_range)
	#生成子弹
	for i in range(real_bullet):
		var ability_instance = ability.instantiate() as FlyThing
		foreground.add_child(ability_instance)
		audio.play()
		ability_instance.scale = init_scale*scale_range
		ability_instance.hitbox_component.damage = int(init_damage*damage_range+randf_range(-3,3))
		ability_instance.global_position=zidan.global_position
		ability_instance.speed =speed
		ability_instance.amount=3
		#散射位置及朝向
		var new_angle = pow(-1,i)*this_angle*i+(enemy_global_position-zidan.global_position).angle()
		ability_instance.direction=Vector2.from_angle(new_angle)
		ability_instance.rotation =new_angle
#
#func on_ability_upgrade_add(upgrade:AbilityUpgrade,_current_upgrade:Dictionary):
	#if upgrade.ID=="枪的伤害":
		#damage_range*=1.3
	#if upgrade.ID=="枪的弹夹":
		#number_range*=1.2
		#wait_range -=0.1
	#if upgrade.ID=="":
		#pass

func end_reload()->void:
	zidan_number.visible=true
	rotation =fmod(fmod(rotation, TAU) + TAU, TAU)
	current_number=number
	_continue.stop()
	audio.stop()
	change_bullet_1.stop()
	change_bullet_2.stop()
