class_name AK47AbilityController
extends Sprite2D

#节点
@export var ability:PackedScene
@onready var reload: Timer = $Reload
@onready var audio: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var change_bullet_1: AudioStreamPlayer2D = $ChangeBullet1
@onready var change_bullet_2: AudioStreamPlayer2D = $ChangeBullet2

@onready var zidan: Node2D = $Zidan
@onready var _continue:Timer = $Continue
@onready var zidan_number: Label = $ZidanNumber


#最大攻击范围,基础数量,攻击间隔,转头间隔
var max_range=200

var number = 30
var number_range :=1.0

var fire_interval:=0.05
var turn_interval :=0.05
#后坐力大小
var recoil_po:float
var recoil_ro_degrees:float

#伤害，大小,速度
var init_damage =15
var damage_range:=1.0

var init_scale:=Vector2(1.0,1.0)
var scale_range :=1.0

var speed =20
var speed_range :=1.0

#冷却，音量,基础位置，从自身节点获得的变量，勿在此改变
var init_position:Vector2

var base_wait_time:float
var wait_range :=1.0 :set = set_wait_range

var volume:=-6.0
var volume_range :=1.0
var change_1_pitch:=1.0
var change_2_pitch:=1.0

var current_number:=0 :set=set_current_number


func _ready() -> void:
	#射程，子弹数量，射击间隔，转头间隔，位置和后坐力
	max_range=160
	number = 30
	fire_interval=0.05
	turn_interval =0.05
	position = Vector2(4.0,6.0)
	recoil_po =return_randf(0.1,0.1)
	recoil_ro_degrees=return_randf(-10,-5)
	#伤害，大小,速度
	init_damage =15
	init_scale=Vector2(1.0,1.0)
	speed =20
	#设置基础参数
	base_wait_time=reload.wait_time
	volume=audio.volume_db
	change_1_pitch = change_bullet_1.pitch_scale
	change_2_pitch = change_bullet_2.pitch_scale
	init_position=self.position
	#连接信号
	reload.timeout.connect(on_reload_out)
	_continue.timeout.connect(on_reload_out)
	GameEvent.ability_upgrade_add.connect(on_ability_upgrade_add)
	#开始射击
	on_reload_out()

func on_ability_upgrade_add(upgrade:AbilityUpgrade,_current_upgrade:Dictionary):
	if upgrade.ID=="枪的伤害":
		damage_range*=1.3
	if upgrade.ID=="枪的弹夹":
		number_range *=1.2
		wait_range -=0.1
	if upgrade.ID=="":
		pass

func on_reload_out()->void:
	#保证换弹结束后不循环
	_continue.stop()
	reload.stop()
	if current_number<=0:
		end_reload()
	#拿到敌人数组
	var enemies=check_enemy()
	while_attack(enemies)

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
	for i in range(int(number*number_range)+1):
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
		return false
	audio.volume_db=volume*volume_range
	#找到没被释放的敌人
	var n=0
	while enemies[n]==null:
		if n==enemies.size()-1:
			_continue.start()
			return false
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
	ability_instance.hitbox_component.damage = int(init_damage*damage_range+randf_range(-3,3))
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
