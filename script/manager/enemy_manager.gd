class_name EnemyManager
extends Node
enum ALL_SHAPE{
	arrow,
	triangle
}

@export var normal_enemy:Array[EnemyUnlockEntry]
@export var all_enemy:Array[EnemyUnlockEntry]
@export var all_shape:Array[PackedScene]
@onready var normal_timer: Timer = $Normal
@onready var special_timer: Timer = $Special
@onready var check_health_timer: Timer = $EnemyProducer/CheckHealth
var enemy_layer:Node
#管理怪物池
var unlocked_group:Array[EnemyUnlockEntry]=[]
var will_back_group:Array[EnemyUnlockEntry]=[]
var all_weight=0
#管理刷怪时间
var base_wait_time:float
var target_time:float
#最小刷怪间隔,刷怪间隔计算
var min_gap_difficulty=15
var decay =0.15
#最大怪物数量
var max_monster :float=900.0
var target_health:float
var all_health:float

func _ready() -> void:
	enemy_layer = get_tree().get_first_node_in_group("enemylayer")
	base_wait_time=normal_timer.wait_time
	GameEvent.more_difficulty.connect(on_more_difficulty)
	match GameEvent.mode_index:
		2:
			decay = 0.2
		3:
			if GameEvent.hard_mode[GameEvent.HARD_MODE.is_more]:
				min_gap_difficulty=23
				decay=0.4
		_:
			decay=0.15
	enemy_filiter()
	normal_timer.start()

func enemy_filiter():
	if ! will_back_group.is_empty():
		for enemy in will_back_group:
			unlocked_group.append(enemy)
	for enemy in normal_enemy:
		if enemy.unlock_difficulty==GameEvent.difficulty:#怪物等级在当前难度等级
			#之内就把他们加入召唤池
			unlocked_group.append(enemy)
			all_weight +=enemy.weight
		elif enemy.disapear_difficulty==GameEvent.difficulty:
			unlocked_group.erase(enemy)
			all_weight -=enemy.weight

func get_weight():
	var _all_weight=0
	for enemy in unlocked_group:
		_all_weight+=enemy.weight 
	all_weight = _all_weight

func random_chose():
	var roll=randf_range(0,all_weight)
	for enemy in unlocked_group:
		roll-=enemy.weight
		if roll<=0:
			if enemy.ID==enemy.ALL_ID.escape_box:
				unlocked_group.erase(enemy)
				will_back_group.append(enemy)
				all_weight-=enemy.weight
			return enemy.scene#拿到这次抽到的怪物

func on_more_difficulty(difficulty):
	target_health= check_health()
	if difficulty<=min_gap_difficulty:
		target_time = base_wait_time * exp(-decay * (difficulty-1))
		normal_timer.wait_time=target_time
	if difficulty==4:
		check_health_timer.start()
		special_timer.start()
	enemy_filiter()

func _on_check_health_timeout() -> void:
	all_health= check_health()
	if target_time:
		var percent = all_health/target_health
		normal_timer.wait_time = target_time*exp(percent-1.5)

func check_health()->float:
	var _all_health=0.0
	for enemy in enemy_layer.get_children():
		if enemy is Enemy:
			for component in enemy.all_component:
				if component is HealthComponent:
					_all_health +=component.max_health
	_all_health = min(_all_health,50)
	return _all_health

func _special_event(just_look:=false):
	if just_look:
		return 1
	else :
		pass
