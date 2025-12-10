extends  Node
const MAX_RANGE=150
@export var heaven_fury:PackedScene
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D

var Damage=25#定义天堂之怒的伤害
var base_wait_time#定义基础冷却
var number=2#定义基础剑的数量
var volume:=-8

func _ready() -> void:
	base_wait_time=$Timer.wait_time
	$Timer.timeout.connect(on_timer_timeoout)
	GameEvent.ability_upgrade_add.connect(on_ability_upgrade_add)
	audio_stream_player_2d
	
func on_timer_timeoout():
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
		var fury_instance = heaven_fury.instantiate() as HeavenFury
		var foreground = get_tree().get_first_node_in_group("前景图层")

		# ② 等节点_ready完成再赋值，避免 nil
		foreground.add_child(fury_instance)
		audio_stream_player_2d.volume_db=volume
		audio_stream_player_2d.play()
		fury_instance.hitbox_component.damage = int(Damage+randf_range(-6,6))
		if enemies.is_empty():
			fury_instance.queue_free()
			return

		var _enemy = enemies[i]
		

		# ③ 位置 & 朝向
		fury_instance.global_position =player.global_position
		var ran_R=randf_range(60,90)
		fury_instance.global_position += Vector2.RIGHT.rotated(randf_range(0, TAU)) * ran_R
		
	

# 再拿最近的那只
	

	
func on_ability_upgrade_add(upgrade:AbilityUpgrade,current_upgrade:Dictionary):

	print("saiuofai")
	#监听所有关于剑的升级
	if upgrade.ID=="更快愤怒":
		var persent_reduction=current_upgrade["更快愤怒"]["quantity"]*.2
		volume=-8-persent_reduction*10
		$Timer.wait_time=max(base_wait_time*(1-persent_reduction),0.5)
		$Timer.start()
	if upgrade.ID=="更强愤怒":
		var _persent_improvement=current_upgrade["更强愤怒"]["quantity"]*.25
		Damage*=1.25
		print(Damage)
	if upgrade.ID=="更多愤怒":
		number+=2
	if upgrade.ID=="解锁天堂之怒":
		print("解锁天堂之怒")
		$Timer.start()
