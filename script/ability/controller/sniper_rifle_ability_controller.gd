extends AK47AbilityController

@onready var lashuan: AudioStreamPlayer2D = $lashuan
@onready var bullet: AudioStreamPlayer2D = $bullet
@onready var lashuan_2: AudioStreamPlayer2D = $lashuan2
var lashuan_2_pitch

func set_variable()->void:
	#射程，子弹数量，射击间隔，转头间隔，位置和后坐力
	max_range=300
	number = 3
	fire_interval=1.0
	turn_interval =0.02
	init_position = Vector2(6.0,-3.0)
	recoil_po =return_randf(0.1,0.3,false)
	recoil_ro_degrees=return_randf(-20,-20)
	#伤害，大小,速度
	init_damage =200
	init_scale=Vector2(3.0,2.0)
	speed =30
	#设置基础参数
	lashuan_2_pitch=lashuan_2.pitch_scale

#专打终极
func check_enemy()->Array[Node]:
	var enemies:Array[Node]= get_tree().get_first_node_in_group("enemylayer").get_children()
	enemies=enemies.filter(func(enemy:Node2D):#过滤掉不在范围内的敌人
		return enemy.global_position.distance_squared_to(GameEvent.play_global_position)<pow(260,2) and enemy is Enemy
	)
	#get_first_node_in_group是拿到组里面的第一个节点，如果我们想要拿到player节点
	#就要在player脚本中加入add_to_group("player")
	enemies.sort_custom(func (a:Node2D,b:Node2D):
		var A_distance=a.global_position.distance_squared_to(GameEvent.play_global_position)
		var B_distance=b.global_position.distance_squared_to(GameEvent.play_global_position)
		return A_distance< B_distance
	)
	enemies.sort_custom(func (a:Node2D,b:Node2D):
		var _a =  a as Enemy
		var _b = b as Enemy
		var a_damage
		var b_damage
		for component in _a.all_component:
			if component is AttackComponent:
				a_damage=component.damage
		for component in _b.all_component:
			if component is AttackComponent:
				b_damage=component.damage
		return a_damage>b_damage
	)
	return enemies

func while_attack(enemies:Array[Node])->void:
	var real_number = int(number)
	if number_range!=1.0:
		real_number=int(number*number_range)+1
	for i in range(real_number):
		#找到敌人，并排除各种问题
		var enemy:Node2D=null
		if i==0:
			enemy = before_attack_find_enemy(enemies)
		elif i>0:
			var new_enemies = check_enemy()
			enemy=before_attack_find_enemy(new_enemies)
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

func attack(enemy_global_position:Vector2)->void:
	#找到落脚点
	var foreground = get_tree().get_first_node_in_group("前景图层")
	#生成子弹,并发出枪声
	var ability_instance = ability.instantiate() as FlyThing
	foreground.add_child(ability_instance)
	audio.play()
	bullet.play()
	#设置基本属性
	ability_instance.scale = init_scale*scale_range
	ability_instance.attack_component.damage = init_damage*damage_range
	ability_instance.global_position=zidan.global_position
	ability_instance.direction=(enemy_global_position-zidan.global_position).normalized()
	ability_instance.rotation = ability_instance.direction.angle()
	ability_instance.speed =speed
	ability_instance.amount=100
	var tween =create_tween().bind_node(ability_instance)
	tween.tween_property(ability_instance,"scale",ability_instance.scale+Vector2(ability_instance.scale.x*2,0),0.05)

func after_attack(enemy_global_position:Vector2)->void:
	current_number-=1
	var direction = (enemy_global_position-zidan.global_position).normalized()
	var tween = get_tree().create_tween()
	#后坐力实现
	var init_rotation = rotation_degrees
	tween.tween_property(self,"position",position-direction*recoil_po,0.05)
	tween.parallel().tween_property(self,"rotation_degrees",rotation_degrees+recoil_ro_degrees,0.05)
	tween.tween_property(self,"rotation_degrees",init_rotation,0.1)
	await bullet.finished
	if current_number!=0:
		lashuan.play()
		await lashuan.finished
	else :
		pass

func set_wait_range(value)->void:
	wait_range=value
	change_bullet_1.pitch_scale = change_1_pitch/wait_range
	change_bullet_2.pitch_scale = change_2_pitch/wait_range
	lashuan_2.pitch_scale = change_2_pitch/wait_range

func _on_change_bullet_2_finished() -> void:
	if ! reload.is_stopped():
		if reload.time_left <=1:
			lashuan_2.play()
			return
		change_bullet_2.play()
