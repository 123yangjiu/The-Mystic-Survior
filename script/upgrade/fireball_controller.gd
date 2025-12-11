extends  Node
const MAX_RANGE=250
@export var fireball:PackedScene

var Damage=18#定义火球的伤害
var base_wait_time#定义基础冷却
var number=1#火球数量
var speed=0.05#火球的速度
var amout=3#初始穿透个数
var ball_size=1#初始化火球大小
var volume:=5
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D

func _ready() -> void:
	base_wait_time=$Timer.wait_time
	get_node("Timer").timeout.connect(on_timer_timeoout)
	GameEvent.ability_upgrade_add.connect(on_ability_upgrade_add)
	
func on_timer_timeoout():
	audio_stream_player_2d.stop()
	var player=get_tree().get_first_node_in_group("player") as Node2D
	var enemies= get_tree().get_nodes_in_group("enemy")
	enemies=enemies.filter(func(enemy:Node2D):#过滤掉不在范围内的敌人
		return enemy.global_position.distance_squared_to(player.global_position)<pow(MAX_RANGE,2)
	
	)
	#get_first_node_in_group是拿到组里面的第一个节点，如果我们想要拿到player节点
	#就要在player脚本中加入add_to_group("player")
	enemies.sort_custom(func (a:Node2D,b:Node2D):
		var A_distance=a.global_position.distance_squared_to(player.global_position)
		var B_distance=b.global_position.distance_squared_to(player.global_position)
		return A_distance< B_distance
	
		
	)
	#print("过滤+排序后敌人数量=", enemies.size())
	var spawn_number=min(enemies.size(),number)
	if spawn_number==0:
		return
	for i in range(spawn_number):
		var fireball_instance = fireball.instantiate() as Fireball
		var foreground = get_tree().get_first_node_in_group("前景图层")
		fireball_instance.scale*=ball_size

		# ② 等节点_ready完成再赋值，避免 nil
		foreground.add_child(fireball_instance)
		audio_stream_player_2d.volume_db=volume
		audio_stream_player_2d.play()
		fireball_instance.hitbox_component.damage = int(Damage+randf_range(-3,3))
		if enemies.is_empty():
			fireball_instance.queue_free()
			return

		var enemy = enemies[i]
		

		# ③ 位置 & 朝向
		fireball_instance.global_position =player.global_position
		#fireball_instance.global_position += Vector2.RIGHT.rotated(randf_range(0, TAU)) * 4
		var dir_to_player = player.global_position - enemy.global_position
		var _offset_deg = randf_range(-10,10)
		#拿到玩家跟敌人的方向
		#dir_to_player = dir_to_player.rotated(deg_to_rad(-90))#火球发射前随机旋转一个小角度
		fireball_instance.direction=dir_to_player
		fireball_instance.velocity=speed
		fireball_instance.ammout=amout
		var base_offset = deg_to_rad(90)
		fireball_instance.global_rotation = dir_to_player.angle()+base_offset
# 再拿最近的那只
	

	
func on_ability_upgrade_add(upgrade:AbilityUpgrade,current_upgrade:Dictionary):

	#print("saiuofai")
	if upgrade.ID=="火球大穿":
		amout+=2
		ball_size +=0.2
	if upgrade.ID=="火球力速":
		Damage*=1.2
		var persent_reduction=current_upgrade["火球力速"]["quantity"]*.15
		volume =-persent_reduction*6
		$Timer.wait_time=base_wait_time*max((1-persent_reduction),0.1)
		$Timer.start()
	if upgrade.ID=="火球数量":
		number+=1
	if upgrade.ID=="解锁火球":
		$Timer.start()
	pass
	##print("saiuofai")
	#if upgrade.ID=="火球大穿":
		#amout+=2
		#ball_size +=0.2
	#if upgrade.ID=="火球力速":
		#Damage*=1.15
		#var persent_reduction=current_upgrade["火球力速"]["quantity"]*.15
		#volume =5-persent_reduction*10
		#$Timer.wait_time=base_wait_time*max((1-persent_reduction),0.1)
		#$Timer.start()
	#if upgrade.ID=="火球数量":
		#number+=1
	#if upgrade.ID=="解锁火球":
		#$Timer.start()
	#pass

	
