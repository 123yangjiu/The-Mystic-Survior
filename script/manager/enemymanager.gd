extends Node
const SPAWN_R=300
@export var kill_cirle_enemy:Array[PackedScene]
var chosen_enemy_scene:PackedScene
var min_gap=0.08
var decay =0.34
var rand_R=450#包围半径
@onready var enemyfiliter: EnemyFiliter = $"../enemyfiliter"
var base_time_gap
func _ready() -> void:
    base_time_gap=$Timer.wait_time
    $Timer.timeout.connect(on_time_out)
    GameEvent.more_difficulty.connect(on_more_difficulty)
func on_time_out():
    chosen_enemy_scene=enemyfiliter.random_chose()#
    var player=get_tree().get_first_node_in_group("player")#通过筛选器选出这次要生成
    #的怪物
    var random_direction=Vector2.RIGHT.rotated(randf_range(0,TAU))
    var spawn_position=player.global_position+random_direction*SPAWN_R
    var enemy=chosen_enemy_scene.instantiate() as Node2D
    var entities_Layer=get_tree().get_first_node_in_group("实体图层")
    entities_Layer.add_child(enemy)
    enemy.global_position=spawn_position
func on_more_difficulty(difficulty:int):
    #print(difficulty)
    var entities_Layer=get_tree().get_first_node_in_group("实体图层")
    var player=get_tree().get_first_node_in_group("player")
    $Timer.wait_time = (max(min_gap, base_time_gap * exp(-decay * difficulty)))*1.15
    if difficulty==3:
        for i in 40:
            var kill_enemy = kill_cirle_enemy[0].instantiate() as Node2D
            entities_Layer.add_child(kill_enemy)
            var angle := TAU * i / 30
            # 2. 半径加 ±10% 随机，避免太机械
            var radius := float(rand_R-50) * randf_range(0.9, 1.1)
            # 3. 最终位置
            kill_enemy.global_position = player.global_position + Vector2.RIGHT.rotated(angle) * radius
    if difficulty==5:
        for i in 3:
            var kill_enemy = kill_cirle_enemy[2].instantiate() as Node2D
            entities_Layer.add_child(kill_enemy)
            var angle := TAU * i / 3
            # 2. 半径加 ±10% 随机，避免太机械
            var radius := float(rand_R) * randf_range(0.9, 1.1)
            # 3. 最终位置
            kill_enemy.global_position = player.global_position + Vector2.RIGHT.rotated(angle) * radius
    if difficulty==8:
        for i in 20:
            var kill_enemy = kill_cirle_enemy[1].instantiate() as Node2D
            entities_Layer.add_child(kill_enemy)
            var angle := TAU * i / 20.0
            # 2. 半径加 ±10% 随机，避免太机械
            var radius := float(rand_R) * randf_range(0.9, 1.1)
            # 3. 最终位置
            kill_enemy.global_position = player.global_position + Vector2.RIGHT.rotated(angle) * radius
    if  difficulty==12:
        for i in 60:
            var kill_enemy = kill_cirle_enemy[0].instantiate() as Node2D
            entities_Layer.add_child(kill_enemy)
            var angle := TAU * i / 30
            # 2. 半径加 ±10% 随机，避免太机械
            var radius := float(rand_R) * randf_range(0.9, 1.1)
            # 3. 最终位置
            kill_enemy.global_position = player.global_position + Vector2.RIGHT.rotated(angle) * radius 
    if  difficulty==14:
        for i in 15:
            var kill_enemy = kill_cirle_enemy[1].instantiate() as Node2D
            entities_Layer.add_child(kill_enemy)
            var angle := TAU * i / 10
            # 2. 半径加 ±10% 随机，避免太机械
            var radius := float(rand_R) * randf_range(0.9, 1.1)
            # 3. 最终位置
            kill_enemy.global_position = player.global_position + Vector2.RIGHT.rotated(angle) * radius 
        for i in 15:
            var kill_enemy = kill_cirle_enemy[2].instantiate() as Node2D
            entities_Layer.add_child(kill_enemy)
            var angle := TAU * i / 15
            # 2. 半径加 ±10% 随机，避免太机械
            var radius := float(rand_R) * randf_range(0.9, 1.1)
            # 3. 最终位置
            kill_enemy.global_position = player.global_position + Vector2.RIGHT.rotated(angle) * radius 			
    if  difficulty==16:
        for i in 8:
            var kill_enemy = kill_cirle_enemy[3].instantiate() as Node2D
            entities_Layer.add_child(kill_enemy)
            var angle := TAU * i / 8
            # 2. 半径加 ±10% 随机，避免太机械
            var radius := float(rand_R) * randf_range(0.9, 1.1)
            # 3. 最终位置
            kill_enemy.global_position = player.global_position + Vector2.RIGHT.rotated(angle) * radius       
