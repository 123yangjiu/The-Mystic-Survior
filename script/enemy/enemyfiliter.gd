extends Node
class_name EnemyFiliter
@export var enemy_group:Array[EnemyUnlockEntry]
var unlocked_group:Array[EnemyUnlockEntry]=[]
var temporarily_group:Array[EnemyUnlockEntry]=[]
var current_difficulty=1
var all_weight=0

func _ready() -> void:
	GameEvent.more_difficulty.connect(on_more_difficulty)
	enemy_filiter()

func enemy_filiter():
	for enemy in temporarily_group:
		unlocked_group.append(enemy)
	for enemy in enemy_group:
		if enemy.unlock_difficulty==current_difficulty:#怪物等级在当前难度等级
			#之内就把他们加入召唤池
			unlocked_group.append(enemy)
			all_weight +=enemy.weight
		elif enemy.disapear_difficulty==current_difficulty:
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
				temporarily_group.append(enemy)
				all_weight-=enemy.weight
			return enemy.scene#拿到这次抽到的怪物

func on_more_difficulty(difficulty):
	current_difficulty=difficulty
	enemy_filiter()
