extends Node
@onready var difficulty_timer: Timer = $difficulty_timer
var paused:=0:set=set_paused

func _ready() -> void:
    difficulty_timer.timeout.connect(emit_more_difficulty)
signal experience_bottle_collected(number:float)#吃到经验瓶时发出信号
func emit_increase_experience(number:float):#发射信号的函数这样写是为了控制经验瓶的经验多少
    experience_bottle_collected.emit(number)


signal ability_upgrade_add(upgrade:AbilityUpgrade,current_upgrade:Dictionary)
#能力升级信号，传出改变的能力和能力字典
func emit_ability_upgrade_add(upgrade:AbilityUpgrade,current_upgrade:Dictionary):
    await get_tree().process_frame
    ability_upgrade_add.emit(upgrade,current_upgrade)
    pass

var difficulty=1#初始难度等级为1
signal more_difficulty(difficulty:int)
func emit_more_difficulty():
    difficulty+=1
    more_difficulty.emit(difficulty)
    
signal blood_bottle_collected(number:float)
func emit_increase_blood(number:float):#发射信号的函数这样写是为了控制经验瓶的经验多少
    blood_bottle_collected.emit(number)

var the_first=0
@warning_ignore("unused_signal")
signal the_first_damage()
@warning_ignore("unused_signal")
signal game_stop #管理双重暂停，例如当升级时再按暂停
@warning_ignore("unused_signal")
signal stop_end
@warning_ignore("unused_signal")
signal player_died

signal _paused #当paused+1时发出信号
#当游戏暂停时发出一些信号
func set_paused(value)->void:
    if value>paused:
        _paused.emit()
    paused=value

#用于记录音量有关数据
var master_db  
var sound_db
var music_db
func record_db(_name:String,value)->void:
    if _name=="Sound":
        sound_db=value
    elif  _name =="Master":
        master_db=value
    elif _name=="Music":
        music_db=value


@warning_ignore("unused_signal")
signal mush_appear #当蘑菇出现时@enemyproducer

#限制出怪量
var current_monster :=0.0

#简单模式：1.怪物移速下降10%；2.刷怪速度下降很多；3.玩家伤害提高10%;4.玩家受伤减少1半
var is_hard:=false
