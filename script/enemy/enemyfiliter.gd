extends Node
class_name EnemyFiliter
@export var enemy_group:Array[EnemyUnlockEntry]
var unlocked_group:Array[EnemyUnlockEntry]=[]
var current_difficulty=1
var all_weight=0

func _ready() -> void:
    GameEvent.more_difficulty.connect(on_more_difficulty)
    GameEvent.more_difficulty.connect(enemy_filiter)
    enemy_filiter()

func enemy_filiter(_difficulty := 0):
    unlocked_group.clear()
    for enemy in enemy_group:
        if enemy.unlock_difficulty<=current_difficulty:#怪物等级在当前难度等级
            #之内就把他们加入召唤池
            unlocked_group.append(enemy)
            print("解锁难度和权重",enemy.unlock_difficulty,"/",enemy.weight)
    if current_difficulty>=5:
        unlocked_group.remove_at(0)
    if  current_difficulty>=7:
        unlocked_group.remove_at(0)
    if  current_difficulty>=10:
        unlocked_group.remove_at(0)
    if  current_difficulty>=15:
        unlocked_group.remove_at(0)
    get_weight()

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
            if enemy.weight<0.5:
                unlocked_group.erase(enemy)
                all_weight-=enemy.weight
            return enemy.scene#拿到这次抽到的怪物
        #else:
            #print(roll,"现在的group：",unlocked_group)     
    
func on_more_difficulty(difficulty):
    print("当前难度等级：",difficulty)
    current_difficulty=difficulty
