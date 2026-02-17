extends  Node
const MAX_RANGE=250
@export var fireball:PackedScene

var Damage=16#定义火球的伤害
var base_wait_time#定义基础冷却
var base_range=1
var number=1#火球数量
var speed=0.05#火球的速度
var amout=4#初始穿透个数
var ball_size=1.0#初始化火球大小
var volume:=-8
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D

func _ready() -> void:
	base_wait_time=$Timer.wait_time
	get_node("Timer").timeout.connect(on_timer_timeoout)
	GameEvent.ability_upgrade_add.connect(on_ability_upgrade_add)

func on_timer_timeoout():
	audio_stream_player_2d.stop()
	var enemies:Array[Node]= check_enemy()
	#print("过滤+排序后敌人数量=", enemies.size())
	while_attack(enemies)
	#var spawn_number=min(enemies.size(),number)
	#if spawn_number==0:
		#return
	#for i in range(spawn_number):
		#var fireball_instance = fireball.instantiate() as Fireball
		#var foreground = get_tree().get_first_node_in_group("前景图层")
		#fireball_instance.scale =ball_size
		## ② 等节点_ready完成再赋值，避免 nil
		#foreground.add_child(fireball_instance)
		#audio_stream_player_2d.volume_db=volume
		#audio_stream_player_2d.play()
		#fireball_instance.hitbox_component.damage = int(Damage+randf_range(-3,3))
		#if enemies.is_empty():
			#fireball_instance.queue_free()
			#return
#
		#var enemy = enemies[i]
		#
#
		## ③ 位置 & 朝向
		#fireball_instance.global_position =player.global_position
		##fireball_instance.global_position += Vector2.RIGHT.rotated(randf_range(0, TAU)) * 4
		#var dir_to_player = player.global_position - enemy.global_position
		#var _offset_deg = randf_range(-10,10)
		##拿到玩家跟敌人的方向
		##dir_to_player = dir_to_player.rotated(deg_to_rad(-90))#火球发射前随机旋转一个小角度
		#fireball_instance.direction=dir_to_player
		#fireball_instance.velocity=speed
		#fireball_instance.ammout=amout
		#var base_offset = deg_to_rad(90)
		#fireball_instance.global_rotation = dir_to_player.angle()+base_offset

func on_ability_upgrade_add(upgrade:AbilityUpgrade,_current_upgrade:Dictionary):
	if upgrade.ID=="火球力穿":
		amout+=2
		Damage*=1.2
	if upgrade.ID=="火球大速":
		ball_size *=1.2
		volume -=2
		base_range-=0.15
		$Timer.wait_time = max(base_wait_time*base_range,0.1)
		$Timer.start()
	if upgrade.ID=="火球数量":
		number+=1
	if upgrade.ID=="解锁火球":
		$Timer.start()

func check_enemy()->Array:
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

func attack(enemy:Node2D)->void:
	var ability_instance = fireball.instantiate()
	var foreground = get_tree().get_first_node_in_group("前景图层")
	ability_instance.scale *= ball_size
	# ② 等节点_ready完成再赋值，避免 nil
	foreground.add_child(ability_instance)
	#发出声音
	audio_stream_player_2d.play()
	ability_instance.hitbox_component.damage = int(Damage+randf_range(-3,3))
	# ③ 位置 & 朝向
	ability_instance.global_position =GameEvent.play_global_position
	var dir_to_player =GameEvent.play_global_position - enemy.global_position
	var _offset_deg = randf_range(-10,10)
	#拿到玩家跟敌人的方向
	ability_instance.direction=dir_to_player
	ability_instance.velocity=speed
	ability_instance.ammout=amout
	var base_offset = deg_to_rad(90)
	ability_instance.global_rotation = dir_to_player.angle()+base_offset

func while_attack(enemies:Array[Node])->void:
	audio_stream_player_2d.volume_db=volume
	var spawn_number=min(enemies.size(),number)
	if spawn_number==0:
		return
	for i in range(spawn_number):
		var enemy = enemies[i]
		while enemy==null:
			i+=1
			enemy=enemies[i]
		attack(enemy)
