extends Node
@onready var difficulty_timer: Timer = $difficulty_timer

#展示是否开启游戏
var is_start:=false

var difficulty=1#初始难度等级为1
signal more_difficulty(difficulty:int)
func emit_more_difficulty():
    difficulty+=1
    more_difficulty.emit(difficulty)

var increase_percent:=1.0

signal experience_bottle_collected(number:float)#吃到经验瓶时发出信号
func emit_increase_experience(number:float):#发射信号的函数这样写是为了控制经验瓶的经验多少
    experience_bottle_collected.emit(number*increase_percent)

signal blood_bottle_collected(number:float)
func emit_increase_blood(number:float):#发射信号的函数这样写是为了控制经验瓶的经验多少
    blood_bottle_collected.emit(number*increase_percent)

signal ability_upgrade_add(upgrade:AbilityUpgrade,current_upgrade:Dictionary)
#能力升级信号，传出改变的能力和能力字典
@export var upgrade_pool:Array[AbilityUpgrade]

func emit_ability_upgrade_add(upgrade:AbilityUpgrade,current_upgrade:Dictionary):
    await get_tree().process_frame
    ability_upgrade_add.emit(upgrade,current_upgrade)
    if upgrade.ID=="增强效果":
        increase_percent*=1.3


#用于在第一次攻击后启动音乐
var the_first=0
@warning_ignore("unused_signal")
signal the_first_damage()
#用于在player死后传输信号
@warning_ignore("unused_signal")
signal player_died
#暂停系统·
var paused:=0:set=set_paused
signal _paused #当paused+1时发出信号,表示游戏暂停
signal always_stop #向设置了always的节点发送信号，表示暂停
signal always_start #让always的节点重新启动
func set_paused(value)->void:
    if value>paused:
        get_tree().paused=true
        _paused.emit()
    if value>=0:
        paused=value
    if paused==0:
        get_tree().paused=false

func stop_game(is_stop_always:=false)->void:
    paused+=1
    if is_stop_always:
        always_stop.emit()

func start(is_start_always:=false)->void:
    paused-=1
    if is_start_always:
        always_start.emit()

#重新设置参数以重开
func re_game()->void:
    difficulty=1
    start(true)
    the_first=0
    get_tree().change_scene_to_file("res://scene/game.scn")
    difficulty_timer.start()

#用于记录音量有关数据，使setting_screen内的数值与实际保持一致
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

#管理摇杆是否固定
var is_fixed:=false :set=set_fixed
signal yaogan_fixed(is_fix:bool)

func set_fixed(value)->void:
    yaogan_fixed.emit(value)
    is_fixed=value

var play_global_position:=Vector2(0,0)
var play_right:=true

#游戏难度
enum EASY_MODE{
    is_slow,
    is_initial,
    is_ascend
}
enum HARD_MODE{
    is_long,
    is_erase_ability,
    is_max_4,
    is_more
}

signal mode_change
#困难模式:1.怪物移速上升10%；2.刷怪速度下降很多；3.玩家下降10%;4.玩家受伤增加1半
var easy_mode:Dictionary[EASY_MODE,Variant]={
    EASY_MODE.is_slow:false,
    EASY_MODE.is_initial:false,
    EASY_MODE.is_ascend:false
}
#0->简单，1-》普通，2-》困难，3-》挑战
var mode_index:=-1 :set=set_mode
func set_mode(value)->void:
    mode_index=value
    if mode_index!=0:
        for i in easy_mode:
            easy_mode[i] =false
    if mode_index!=2:
        pass
    if mode_index!=3:
        for i in hard_mode:
            hard_mode[i] =false
    mode_change.emit()
#挑战模式：1.游戏时长加长5分钟；2.减少一个自带能力；3.所有能力最多获得三次;
var hard_mode:Dictionary[HARD_MODE,Variant]={
    HARD_MODE.is_long:false,
    HARD_MODE.is_erase_ability:false,
    HARD_MODE.is_max_4:false,
    HARD_MODE.is_more:false
}
#特殊事件
var is_co_disappear:=false
@warning_ignore("unused_signal")
signal collision_disappear
@warning_ignore("unused_signal")
signal collision_disappear_end
