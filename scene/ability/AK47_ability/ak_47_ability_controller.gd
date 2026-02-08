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


#最大攻击范围，基础伤害，基础冷却，基础大小,基础音量
var max_range=200
var init_damage =7
var damage_range:=1.0
var base_wait_time:float
var wait_range :=1.0
var init_scale:=Vector2(1.0,1.0)
var scal_range :=1.0
var volume:=-6.0
var volume_range :=1.0

#基础数量，基础速度,基础攻击间隔
var number = 30
var number_range :=1.0
var speed =20
var speed_range :=1.0
var init_position:Vector2
var fire_interval:=0.1

var current_number:=0 :set=set_current_number


func _ready() -> void:
	#最大攻击范围，基础伤害，基础冷却，基础大小,基础音量
	max_range=200
	init_damage =15
	init_scale=Vector2(1.0,1.0)
	volume=-6.0
	#基础数量，基础速度
	number = 30
	speed =20
	base_wait_time=reload.wait_time
	volume=audio.volume_db
	position = Vector2(0,-38.0)
	init_position=self.position
	reload.timeout.connect(on_reload_out)
	_continue.timeout.connect(on_reload_out)
	GameEvent.ability_upgrade_add.connect(on_ability_upgrade_add)
	print("ak47来了")
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
	print("换弹结束")
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

func attack(enemy_global_position:Vector2)->void:
	var ability_instance = ability.instantiate() as FlyThing
	var foreground = get_tree().get_first_node_in_group("前景图层")
	ability_instance.scale = init_scale*scal_range
	# ② 等节点_ready完成再赋值，避免 nil
	foreground.add_child(ability_instance)
	#发出声音
	audio.play()
	ability_instance.hitbox_component.damage = int(init_damage*damage_range+randf_range(-3,3))
	# ③ 位置 & 朝向
	var tween = get_tree().create_tween().set_parallel()
	tween.tween_property(self,"position",position+Vector2(randfn(-0.2,1),randfn(0,1)),0.05)
	ability_instance.global_position=zidan.global_position
	ability_instance.direction=(enemy_global_position-zidan.global_position).normalized()
	ability_instance.rotation = ability_instance.direction.angle()
	ability_instance.speed =speed

func while_attack(enemies:Array[Node])->void:
	if enemies.is_empty():
		_continue.start()
		return
	var n=0
	audio.volume_db=volume
	for i in range(number+1):
		while enemies[n]==null:
			if n==enemies.size()-1:
				_continue.start()
				return
			n+=1
		var enemy = enemies[n]
		#将枪头对准enemy
		var tween = get_tree().create_tween()
		var direction =(enemy.global_position-zidan.global_position).normalized()
		if i==0:
			tween.tween_property(self,"rotation",direction.angle(),0.1)
		else :
			tween.tween_property(self,"rotation",direction.angle(),fire_interval)
		#await tween.finished
		attack(enemy.global_position)
		current_number-=1
		if current_number<=0:
			start_reload()
			return
		await get_tree().create_timer(fire_interval).timeout

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
	var percent = int(rotation/PI)
	rotation-=percent*PI
	current_number=number
	_continue.stop()
	audio.stop()
	change_bullet_1.stop()
	change_bullet_2.stop()

func _on_change_bullet_2_finished() -> void:
	if ! reload.is_stopped():
		change_bullet_2.play()
