extends AK47AbilityController


var bullet_number:=10.0
var max_angle :=PI/6
var angle_min:=0.2

func _ready() -> void:
	#最大攻击范围，基础伤害，基础冷却，基础大小,基础音量
	max_range=150
	init_damage =25
	init_scale=Vector2(1.0,1.0)
	volume=-6.0
	#基础数量，基础速度,基础攻击间隔
	number = 2
	speed =15
	fire_interval=0.2
	base_wait_time=reload.wait_time
	volume=audio.volume_db
	position=Vector2(-1.0,-28.0)
	init_position=self.position
	reload.timeout.connect(on_reload_out)
	_continue.timeout.connect(on_reload_out)
	GameEvent.ability_upgrade_add.connect(on_ability_upgrade_add)
	on_reload_out()
	print("霰弹来了")

func attack(enemy_global_position)->void:
	#发出声音
	print("霰弹攻击")
	audio.play()
	var foreground = get_tree().get_first_node_in_group("前景图层")
	var direction =(enemy_global_position-zidan.global_position).normalized()
	var dirextion_angle = direction.angle()
	var tween = get_tree().create_tween().set_parallel()
	tween.tween_property(self,"position",position+Vector2(randfn(-0.2,1),randfn(0,1)),0.05)
	#霰弹枪生成子弹
	var real_bullet = int(bullet_number*number_range)+1
	var this_angle =float(max_angle)/(bullet_number*number_range)
	for i in range(real_bullet):
		var ability_instance = ability.instantiate() as FlyThing
		foreground.add_child(ability_instance)
		ability_instance.scale = init_scale*scal_range
		ability_instance.hitbox_component.damage = int(init_damage*damage_range+randf_range(-3,3))
		# ③ 位置 & 朝向
		ability_instance.global_position=zidan.global_position
		ability_instance.speed =speed
		var new_angle = pow(-1,i)*this_angle*i+dirextion_angle
		ability_instance.direction=Vector2.from_angle(new_angle)
		ability_instance.rotation =new_angle
		ability_instance.amount=2

func on_ability_upgrade_add(upgrade:AbilityUpgrade,_current_upgrade:Dictionary):
	if upgrade.ID=="枪的伤害":
		damage_range*=1.3
	if upgrade.ID=="枪的弹夹":
		number_range*=1.2
		wait_range -=0.1
	if upgrade.ID=="":
		pass
