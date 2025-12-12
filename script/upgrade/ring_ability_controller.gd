extends Node
const MAX_RANGE=200
@export var ring_ability:PackedScene
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D

var Damage=11#定义的伤害
var base_wait_time#定义基础冷却
var base_scale=1#定义光剑基础大小
var volume:=4 #声音大小
var color_A :=255 #透明度
var _speed_scale :=1.0#动画速度

func _ready() -> void:
	base_wait_time=$Timer.wait_time
	$Timer.timeout.connect(on_timer_timeoout)
	GameEvent.ability_upgrade_add.connect(on_ability_upgrade_add)
	

func on_timer_timeoout():
	
	var player=get_tree().get_first_node_in_group("player") as Player
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
	
	
	var ring_instance = ring_ability.instantiate() as Ring
	var foreground = get_tree().get_first_node_in_group("前景图层")
		# ② 等节点_ready完成再赋值，避免 nil
	foreground.add_child(ring_instance)#加入到场景中
	audio_stream_player_2d.volume_db=volume
	ring_instance.scale*=base_scale
	ring_instance.modulate.a8 =color_A
	ring_instance.animated_sprite_2d.speed_scale=_speed_scale
	audio_stream_player_2d.play()
	ring_instance.hitbox_component.damage =int(Damage+randf_range(-2,2))
	if enemies.is_empty():
		ring_instance.queue_free()
		return
		
		 # ③ 位置 & 朝向
	ring_instance.global_position =player.global_position
		

# 再拿最近的那只
	

	
func on_ability_upgrade_add(upgrade:AbilityUpgrade,current_upgrade:Dictionary):



	#监听所有关于剑的升级
	print("解锁成功")
	if upgrade.ID=="环的大速":
		var persent_reduction=current_upgrade["环的大速"]["quantity"]*.2
		volume = 4-6*persent_reduction
		color_A = 255-persent_reduction*150
		base_scale*=1.15
		if persent_reduction==1:
			_speed_scale=1.5
		$Timer.wait_time=max(base_wait_time*(1-persent_reduction),0.8)
		$Timer.start()
	if upgrade.ID=="环的伤害":
		Damage=(Damage+2)*1.25
		print(Damage)
	if upgrade.ID=="解锁法环":
		$Timer.start()
		
	pass	
