extends Node

@export var enemy_manager:EnemyManager

var enemy_layer:Node
#管理特殊事件
var all_special_event:Array[Callable]=[]
var all_threat_event:Array[Callable]=[]
#生成时与玩家的距离
var SPAWN_R=350
#地图边界尺寸
const left_limit = -2700
const top_limit = -2000
const right_limit = 2160
const bottom_limit = 2360

func _ready() -> void:
	enemy_layer= get_tree().get_first_node_in_group("enemylayer")
	GameEvent.more_difficulty.connect(on_more_difficulty)
	#添加固定事件
	all_special_event.append(line_front)
	all_special_event.append(circle_interval)
	all_special_event.append(circle_surround)
	all_threat_event.append(mushroom_circle) 
	all_threat_event.append(collision_disappear)
	all_threat_event.append(boss_come)
	#测试内容
	await get_tree().create_timer(3.0).timeout

func on_more_difficulty(difficulty):
	#设置固定事件
	match difficulty:
		3:
			var enemy = find_enemy(EnemyUnlockEntry.ALL_ID.escape_box)
			single_appear(enemy)
		9:
			mushroom_circle()
		11:
			var enemy = find_enemy(EnemyUnlockEntry.ALL_ID.knight)
			single_appear(enemy)
		16:
			var enemy = find_enemy(EnemyUnlockEntry.ALL_ID.knight)
			circle_surround(enemy,500.0,3,5.0)
		20:
			var enemy = find_enemy(EnemyUnlockEntry.ALL_ID.undead)
			single_appear(enemy)
	if difficulty>=13 and difficulty%2 ==1:
		var enemy = find_enemy(EnemyUnlockEntry.ALL_ID.witch)
		single_appear(enemy)
		#加入女巫

func _on_normal_timeout() -> void:
	#通过筛选器选出这次要生成的怪物
	var chosen_enemy_scene=enemy_manager.random_chose()
	var random_direction=Vector2.RIGHT.rotated(randf_range(0,TAU))
	var spawn_position=GameEvent.play_global_position+random_direction*SPAWN_R*randf_range(0.7,1)
	var enemy=chosen_enemy_scene.instantiate() as Enemy
	enemy_layer.add_child(enemy)
	enemy.global_position=limit_position(spawn_position)

func _on_special_timeout() -> void:
	if GameEvent.difficulty>=10:
		var percent = 1*exp(-0.05*(GameEvent.difficulty-1))
		if percent-randf()>=-0.15:
			normal_special()
		else:
			real_special()
	else :
		normal_special()

func find_enemy(id:EnemyUnlockEntry.ALL_ID)->EnemyUnlockEntry:
	var _enemy=null
	for enemy in enemy_manager.all_enemy:
		if enemy.ID == id:
			_enemy=enemy
	return _enemy

func find_shape(id:EnemyManager.ALL_SHAPE)->EnemyShape:
	var enemy_shape =null
	for shape in enemy_manager.all_shape:
		var instance = shape.instantiate() as EnemyShape
		if instance.type == id:
			enemy_shape=instance
	return enemy_shape

func normal_special():
	#先随机选出事件
	var rangdf_index = randi_range(0,all_special_event.size()-1)
	var gap = GameEvent.difficulty-rangdf_index
	var event :Callable= all_special_event.get(rangdf_index)
	#再按照一定限度选取敌人
	var ready_enemy:Array[EnemyUnlockEntry]
	for enemy in enemy_manager.unlocked_group:
		if enemy.unlock_difficulty<gap+1 and enemy.ID!=EnemyUnlockEntry.ALL_ID.escape_box:
			ready_enemy.append(enemy)
	var choose_enemy = ready_enemy.pick_random()
	event.call(choose_enemy)
	print("一般事件：",rangdf_index)

func real_special():
	var event :Callable= all_threat_event.pick_random()
	event.call()

func single_appear(enemy:EnemyUnlockEntry,distance:=500.0)->void:
	circle_surround(enemy,distance,1)

func line_front(enemy:EnemyUnlockEntry,wave:=2,wait_time:=4.0,distance:=280.0)->void:
	for i in wave:
		var index = randi_range(0,enemy_manager.all_shape.size()-1)
		var _shape = enemy_manager.all_shape.get(index).instantiate() as EnemyShape
		enemy_layer.add_child(_shape)
		var angle = randf_range(0,TAU)
		_shape.global_position= GameEvent.play_global_position+Vector2.RIGHT.rotated(angle)*distance
		_shape.global_rotation = angle+PI
		for enemy_position:Node2D in _shape.all_enemy.get_children():
			var position = enemy_position.global_position
			var kill_enemy = enemy.scene.instantiate() as Enemy
			enemy_layer.add_child(kill_enemy)
			kill_enemy.global_position= limit_position(position)
			for component in kill_enemy.all_component:
				if component is VelocityController:
					component.acceleration=0
					component.turn_rate=0
					component.velocity =component.speed*Vector2.RIGHT.rotated(angle+PI)*2.0
					component.is_initial=false
				elif component is CollisionComponent:
					component.collision_shape_2d.disabled=true
			var disappear_component = preload("uid://0uu7d2cwajsq").instantiate() as DisappearComponent
			kill_enemy.add_child(disappear_component)
			disappear_component.disappear_time=3.0
			disappear_component.owner = kill_enemy
		_shape.queue_free()
		await get_tree().create_timer(wait_time).timeout

func circle_interval(enemy:EnemyUnlockEntry,wave:=3,s_radius:=230.0,number:=18,wait_time:=0.09)->void:
	for j in wave:
		await circle_surround(enemy,s_radius*(10+j*2)/10,number,wait_time,false,pow(-1,j))
		await get_tree().create_timer(0.2,false).timeout

func circle_surround(enemy:EnemyUnlockEntry,s_radius:=420.0,number:=70.0,wait_time:=0.0,is_slow:=true,direction:=1.0)->void:
	for i in number:
		var kill_enemy = enemy.scene.instantiate() as Enemy
		enemy_layer.add_child(kill_enemy)
		#半径全随机
		var angle = TAU*i*direction/number
		# 2. 半径加 ±10% 随机，避免太机械
		var radius := float(s_radius) + randf_range(-s_radius/50.0,s_radius/50.0)
		# 3. 最终位置
		kill_enemy.global_position = limit_position(GameEvent.play_global_position + Vector2.RIGHT.rotated(angle) * radius)
		if is_slow:
			for component in kill_enemy.all_component:
				if component is VelocityController:
					component.speed *=0.5
					component.turn_rate *=0.5
		if wait_time!=0:
			await get_tree().create_timer(wait_time,false).timeout

func limit_position(which_position)->Vector2:
	var final_position:Vector2
	final_position.x= min(right_limit,which_position.x)
	final_position.x = max(left_limit,which_position.x)
	final_position.y = min(bottom_limit,which_position.y)
	final_position.y = max(top_limit,which_position.y)
	return final_position
#特殊事件
func mushroom_circle()->void:
	var enemy = find_enemy(EnemyUnlockEntry.ALL_ID.mushroom)
	circle_surround(enemy,450.0,55)
	circle_surround(enemy,400.0,50)

func collision_disappear()->void:
	GameEvent.collision_disappear.emit()
	GameEvent.is_co_disappear=true
	await get_tree().create_timer(12,false).timeout
	GameEvent.collision_disappear_end.emit()
	GameEvent.is_co_disappear=false

func boss_come()->void:
	var number = int(pow(1.06,GameEvent.difficulty))+1
	for i in number:
		var enemy = enemy_manager.special_enemy.pick_random() as EnemyUnlockEntry
		if enemy.ID==EnemyUnlockEntry.ALL_ID.undead:
			var index = randi_range(0,1)
			enemy = enemy_manager.special_enemy.get(index)
		single_appear(enemy)
		await get_tree().create_timer(3.0,false).timeout
