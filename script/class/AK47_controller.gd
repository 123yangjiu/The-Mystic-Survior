extends FlyAbilityController
class_name AK47AbilityController
@onready var reload: Timer = $Reload
@onready var change_bullet_1: AudioStreamPlayer2D = $ChangeBullet1
@onready var change_bullet_2: AudioStreamPlayer2D = $ChangeBullet2

@onready var zidan: Node2D = $Zidan
@onready var _continue:Timer = $Continue
@onready var zidan_number: Label = $ZidanNumber


#最大攻击范围,基础数量,攻击间隔,转头间隔

var fire_interval:=0.05
var turn_interval :=0.05
#后坐力大小
var recoil_po:float
var recoil_ro_degrees:float

#伤害，大小,速度

#冷却，音量,基础位置，从自身节点获得的变量，勿在此改变
var change_1_pitch:=1.0
var change_2_pitch:=1.0

var current_number:=0 :set=set_current_number

func _ready() -> void:
	set_variable()
	#设置基础参数
	base_wait_time=reload.wait_time
	volume=audio.volume_db
	change_1_pitch = change_bullet_1.pitch_scale
	change_2_pitch = change_bullet_2.pitch_scale
	init_position=self.position
	#连接信号
	reload.timeout.connect(on_timer_timeout)
	_continue.timeout.connect(on_timer_timeout)
	GameEvent.ability_upgrade_add.connect(on_ability_upgrade_add)
	var player = get_tree().get_first_node_in_group("实体图层").get_child(0)
	remove_child(zidan_number)
	player.add_child.call_deferred(zidan_number)
	zidan_number.position=Vector2(-20.0,-40.0)
	#开始射击
	on_timer_timeout()

func set_variable()->void:
	#射程，子弹数量，射击间隔，转头间隔，位置和后坐力
	max_range=160
	number = 30
	fire_interval=0.05
	turn_interval =0.05
	recoil_po =return_randf(0.1,0.2,false)
	recoil_ro_degrees=return_randf(-10,-5)
	#伤害，大小,速度
	init_damage =12
	init_scale=Vector2(1.0,1.0)
	speed =20

func on_ability_upgrade_add(upgrade:AbilityUpgrade,_current_upgrade:Dictionary):
	if upgrade.ID=="枪的伤害":
		damage_range*=1.3
	if upgrade.ID=="枪的弹夹":
		number_range *=1.2
		wait_range -=0.1
	if upgrade.ID=="":
		pass

func on_timer_timeout()->void:
	#保证换弹结束后不循环
	_continue.stop()
	reload.stop()
	if current_number<=0:
		end_reload()
	#拿到敌人数组
	var enemies=check_enemy()
	while_attack(enemies)

func while_attack(enemies:Array[Node])->void:
	var real_number = int(number)
	if number_range!=1.0:
		real_number=int(number*number_range)+1
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

func before_attack_find_enemy(enemies:Array[Node]):
	#防止空数组
	if enemies.is_empty():
		_continue.start()
		return null
	audio.volume_db=volume*volume_range
	#找到没被释放的敌人
	var n=0
	while enemies[n]==null:
		if n==enemies.size()-1:
			_continue.start()
			return null
		n+=1
	var enemy :Node2D= enemies[n]
	return enemy

func turnto_enemy(enemy_global_position:Vector2)->void:
	var direction =(enemy_global_position-zidan.global_position).normalized()
	var tween = get_tree().create_tween()
	tween.tween_property(self,"rotation",direction.angle(),turn_interval)
	#使用协程
	await tween.finished

func attack(enemy_global_position:Vector2)->void:
	#找到落脚点
	var foreground = get_tree().get_first_node_in_group("前景图层")
	#生成子弹,并发出枪声
	var ability_instance = ability.instantiate() as FlyThing
	foreground.add_child(ability_instance)
	audio.play()
	#设置基本属性
	ability_instance.scale = init_scale*scale_range
	ability_instance.attack_component.damage = init_damage*damage_range
	ability_instance.global_position=zidan.global_position
	ability_instance.direction=(enemy_global_position-zidan.global_position).normalized()
	ability_instance.rotation = ability_instance.direction.angle()
	ability_instance.speed =speed
	var tween =create_tween().bind_node(ability_instance)
	tween.tween_property(ability_instance,"scale",ability_instance.scale+Vector2(ability_instance.scale.x,0),0.05)

func after_attack(enemy_global_position:Vector2)->void:
	current_number-=1
	var direction = (enemy_global_position-zidan.global_position).normalized()
	var tween = get_tree().create_tween()
	#后坐力实现
	tween.tween_property(self,"position",position-direction*recoil_po,fire_interval/2)
	tween.parallel().tween_property(self,"rotation_degrees",rotation_degrees+recoil_ro_degrees,fire_interval/2)
	tween.tween_property(self,"rotation_degrees",rotation_degrees-recoil_ro_degrees,fire_interval/2)
	await tween.finished

func set_current_number(value)->void:
	var percent = float(value)/float(number)
	current_number=value
	zidan_number.text= str(current_number)
	zidan_number.self_modulate=Color.from_hsv(0.108, 0.73, percent, 1.0)
	if current_number<=0:
		_continue.stop()

func start_reload()->void:
	reload.wait_time=base_wait_time*wait_range
	reload.start()
	var tween = get_tree().create_tween().set_ease(Tween.EASE_OUT).set_parallel()
	tween.tween_property(self,"rotation_degrees",504*reload.wait_time,reload.wait_time)
	tween.tween_property(self,"position",init_position,reload.wait_time)
	zidan_number.visible=false
	change_bullet_1.play()
	await change_bullet_1.finished
	change_bullet_2.play()

func end_reload()->void:
	zidan_number.visible=true
	rotation =fmod(fmod(rotation, TAU) + TAU, TAU)
	if number_range==1.0:
		current_number=number
	else :
		current_number=int(number*number_range)+1
	_continue.stop()
	audio.stop()
	change_bullet_1.stop()
	change_bullet_2.stop()

func _on_change_bullet_2_finished() -> void:
	if ! reload.is_stopped():
		change_bullet_2.play()

func return_randf(from:float,to:float,is_n:=true)->float:
	if is_n:
		return randfn((from+to)/2,1)
	else :
		return randf_range(from,to)

func set_wait_range(value)->void:
	wait_range=value
	change_bullet_1.pitch_scale = change_1_pitch/wait_range
	change_bullet_2.pitch_scale = change_2_pitch/wait_range
