extends Node
var SPAWN_R=300
#地图边界尺寸
const left_limit=-2700
const top_limit = -2000
const right_limit =2160
const bottom_limit = 2360
@onready var timer: Timer = $Timer
@export var kill_cirle_enemy:Array[PackedScene]
@export var special_enemy:Array[EnemyUnlockEntry]
#最大怪物数量
var max_monster :float=900.0
#最小刷怪间隔
var min_gap=0.12
var decay =0.25
var target_time:float

var chosen_enemy_scene:PackedScene

var rand_R=450#包围半径
@onready var enemyfiliter: EnemyFiliter = $"../enemyfiliter"
var base_time_gap

func _ready() -> void:
	base_time_gap=timer.wait_time
	timer.timeout.connect(on_time_out)
	GameEvent.more_difficulty.connect(on_more_difficulty)
	match GameEvent.mode_index:
		2:
			min_gap =0.07
			decay = 0.33
		3:
			if GameEvent.hard_mode[GameEvent.HARD_MODE.is_more]:
				min_gap=0.04
				decay=0.4

func on_time_out():
	chosen_enemy_scene=enemyfiliter.random_chose()#
#通过筛选器选出这次要生成的怪物
	var random_direction=Vector2.RIGHT.rotated(randf_range(0,TAU))
	var spawn_position=GameEvent.play_global_position+random_direction*SPAWN_R*randf_range(0.5,1)
	var enemy=chosen_enemy_scene.instantiate() as Node2D
	var entities_Layer=get_tree().get_first_node_in_group("enemylayer")
	entities_Layer.add_child(enemy)
	enemy.global_position=limit_position(spawn_position)
	if target_time:
		timer.wait_time=target_time*(exp(GameEvent.current_monster/max_monster)-0.2)

func on_more_difficulty(difficulty:int):
	var entities_Layer=get_tree().get_first_node_in_group("enemylayer")
	var player=get_tree().get_first_node_in_group("player")
	timer.wait_time = (max(min_gap, base_time_gap * exp(-decay * difficulty)))*1.15
	target_time=timer.wait_time
	if difficulty==3:
		var kill_enemy = kill_cirle_enemy[6].instantiate() as Node2D
		entities_Layer.add_child(kill_enemy)
		var angle := TAU*randf()
		# 2. 半径加 ±10% 随机，避免太机械
		var radius := float(rand_R) * randf_range(0.2,0.4)
		# 3. 最终位置
		kill_enemy.global_position = player.global_position + Vector2.RIGHT.rotated(angle) * radius
	elif difficulty==5:
		var now_player_position = GameEvent.play_global_position
		for i in 75:
			var kill_enemy = kill_cirle_enemy[5].instantiate() as Node2D
			entities_Layer.add_child(kill_enemy)
			var angle := TAU*i/ 20
			var radius := float(rand_R) * 0.7
			if i>40:
				radius *=1.5
			# 3. 最终位置
			kill_enemy.global_position = now_player_position + Vector2.RIGHT.rotated(angle) * radius
			await get_tree().create_timer(0.1).timeout
	elif difficulty==9:
		on_mush_appear()
		for i in 80:
			var kill_enemy = kill_cirle_enemy[0].instantiate() as Node2D
			entities_Layer.add_child(kill_enemy)
			var angle := TAU * i / 80.0
			# 2. 半径加 ±10% 随机，避免太机械
			var radius := float(rand_R) * randf_range(0.9, 1.1)
			# 3. 最终位置
			kill_enemy.global_position = player.global_position + Vector2.RIGHT.rotated(angle) * radius
	elif difficulty==10:
		var kill_enemy = kill_cirle_enemy[1].instantiate() as Node2D
		entities_Layer.add_child(kill_enemy)
		var angle := TAU / 60.0
		# 2. 半径加 ±10% 随机，避免太机械
		var radius := float(rand_R) * randf_range(0.9, 1.1)
		# 3. 最终位置
		kill_enemy.global_position = player.global_position + Vector2.RIGHT.rotated(angle) * radius
	elif  difficulty==12:
		for i in 80.0:
			var kill_enemy = kill_cirle_enemy[0].instantiate() as Node2D
			entities_Layer.add_child(kill_enemy)
			var angle := TAU * i / 80
			# 2. 半径加 ±10% 随机，避免太机械
			var radius := float(rand_R) * randf_range(0.9, 1.1)
			# 3. 最终位置
			kill_enemy.global_position = player.global_position + Vector2.RIGHT.rotated(angle) * radius 
	elif difficulty==13:
		for i in 1:
			var kill_enemy = kill_cirle_enemy[1].instantiate() as Node2D
			entities_Layer.add_child(kill_enemy)
			var angle := TAU *i/ 3
			# 2. 半径加 ±10% 随机，避免太机械
			var radius := float(rand_R) * randf_range(0.9, 1.1)
			# 3. 最终位置
			kill_enemy.global_position = player.global_position + Vector2.RIGHT.rotated(angle) * radius
	elif difficulty==14:
		var now_player_position = GameEvent.play_global_position
		for i in 50:
			var kill_enemy = kill_cirle_enemy[4].instantiate() as Node2D
			entities_Layer.add_child(kill_enemy)
			var angle := TAU*i/ 20
			# 2. 半径加 ±10% 随机，避免太机械
			var radius := float(rand_R) * 0.7
			# 3. 最终位置
			kill_enemy.global_position = now_player_position + Vector2.RIGHT.rotated(angle) * radius
			await get_tree().create_timer(0.1).timeout
	elif  difficulty==15:
		on_mush_appear()
		for i in 80:
			var kill_enemy = kill_cirle_enemy[0].instantiate() as Node2D
			entities_Layer.add_child(kill_enemy)
			var angle := TAU * i / 80
			# 2. 半径加 ±10% 随机，避免太机械
			var radius := float(rand_R) * randf_range(0.9, 1.1)
			# 3. 最终位置
			kill_enemy.global_position = player.global_position + Vector2.RIGHT.rotated(angle) * radius        
	elif  difficulty==16:
		for i in 3:
			var kill_enemy = kill_cirle_enemy[1].instantiate() as Node2D
			entities_Layer.add_child(kill_enemy)
			var angle := TAU *i/ 3
			# 2. 半径加 ±10% 随机，避免太机械
			var radius := float(rand_R) * randf_range(0.9, 1.1)
			# 3. 最终位置
			kill_enemy.global_position = player.global_position + Vector2.RIGHT.rotated(angle) * radius
			if i < 2:  # 当 i = 0, 1 时等待，i = 2 时不等待
				await get_tree().create_timer(4.0).timeout
	elif  difficulty==17:
		var now_player_position = GameEvent.play_global_position
		for i in 60:
			var kill_enemy = kill_cirle_enemy[3].instantiate() as Node2D
			entities_Layer.add_child(kill_enemy)
			var angle := TAU *i/ 20
			# 2. 半径加 ±10% 随机，避免太机械
			var radius := float(rand_R) * randf_range(0.9, 1.1)
			if i>30:
				radius *=1.5
			# 3. 最终位置
			kill_enemy.global_position =  now_player_position + Vector2.RIGHT.rotated(angle) * radius
			await get_tree().create_timer(0.15).timeout
	if difficulty>=13 and difficulty%2 ==1:
		var kill_enemy = kill_cirle_enemy[2].instantiate() as Node2D
		entities_Layer.add_child(kill_enemy)
		var angle := TAU / 3
		# 2. 半径加 ±10% 随机，避免太机械
		var radius := float(rand_R) * randf_range(0.9, 1.1)
		# 3. 最终位置
		kill_enemy.global_position = player.global_position + Vector2.RIGHT.rotated(angle) * (radius+50)
		#加入女巫

func limit_position(which_position)->Vector2:
    var final_position:Vector2
    final_position.x= min(right_limit,which_position.x)
    final_position.x = max(left_limit,which_position.x)
    final_position.y = min(bottom_limit,which_position.y)
    final_position.y = max(top_limit,which_position.y)
    return final_position

func on_mush_appear()->void:
	await get_tree().create_timer(1).timeout
	var ori_time = timer.wait_time
	timer.wait_time= (max(min_gap, base_time_gap * exp(-decay * GameEvent.difficulty*0.2)))*1.15
	SPAWN_R = 250
	await get_tree().create_timer(19).timeout
	SPAWN_R=300
	if timer.wait_time >ori_time:
		timer.wait_time=ori_time
