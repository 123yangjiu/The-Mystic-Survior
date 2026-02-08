extends AK47AbilityController

@onready var lashuan: AudioStreamPlayer2D = $lashuan
@onready var bullet: AudioStreamPlayer2D = $bullet


func _ready() -> void:
	#射程，子弹数量，射击间隔，转头间隔，位置和后坐力
	max_range=300
	number = 3
	fire_interval=1.0
	turn_interval =0.02
	position = Vector2(9.0,4.0)
	recoil_po =return_randf(0.1,0.1)
	recoil_ro_degrees=return_randf(-20,-20)
	#伤害，大小,速度
	init_damage =200
	init_scale=Vector2(3.0,2.0)
	speed =30
	#设置基础参数
	base_wait_time=reload.wait_time
	volume=audio.volume_db
	change_1_pitch = change_bullet_1.pitch_scale
	change_2_pitch = change_bullet_2.pitch_scale
	init_position=self.position
	reload.timeout.connect(on_reload_out)
	_continue.timeout.connect(on_reload_out)
	GameEvent.ability_upgrade_add.connect(on_ability_upgrade_add)
	on_reload_out()

#专打终极
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
	enemies.sort_custom(func (a:Node2D,b:Node2D):
		var is_A_level = a.is_in_group("终极")
		var is_B_level = b.is_in_group("终极")
		return is_A_level and ! is_B_level
	)
	return enemies

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
	ability_instance.hitbox_component.damage = int(init_damage*damage_range+randf_range(-3,3))
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
