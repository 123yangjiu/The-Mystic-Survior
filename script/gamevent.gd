extends Node
@onready var difficulty_timer: Timer = $difficulty_timer

func _ready() -> void:
	#还没选过难度时默认普通（mode_index 的 -1 表示"还没选"）
	if mode_index < 0:
		mode_index = 1

#---- 启动游戏需要 ----

func refresh()->void:
	is_start=false
	#初始难度
	difficulty=1
	#各种瓶子效果
	increase_percent=1.0
	#启动音乐相关
	the_first=0
	paused = 0
	#难度计时开始
	difficulty_timer.start()
	#特殊事件相关
	is_co_disappear=false

#启动测试场景
func test()->void:
	difficulty_timer.one_shot=true

#---- 大厅 ↔ 一局游戏 ----
#（原来这两件事分别写在主界面的“开始游戏”按钮和结算界面的“返回主界面”里，
#  取消主界面之后统一放在这里，谁想开始/结束一局都调用这两个函数）

#开始一局：把难度、各种计时器和暂停状态都重置成开局的样子
func begin_run()->void:
	start(true)
	paused=0
	difficulty=1
	the_first=0
	is_start=true
	is_co_disappear=false
	increase_percent=1.0
	difficulty_timer.start()

#回到大厅：清掉上一局留下的暂停、难度，大厅里不需要推进难度计时器
func end_run()->void:
	paused=0
	is_start=false
	difficulty=1
	the_first=0
	is_co_disappear=false
	increase_percent=1.0
	#启动时主场景的 _enter_tree 可能比自动加载的 _ready 更早，这里判一下空
	if difficulty_timer:
		difficulty_timer.stop()

#展示是否开启游戏
var is_start:=false
#胜利信号
@warning_ignore("unused_signal")
signal victory
#初始难度等级为1
var difficulty=1
signal more_difficulty(difficulty:int)

func emit_more_difficulty():
	difficulty+=1
	more_difficulty.emit(difficulty)

#有关影响瓶子效果的能力
var increase_percent:=1.0

signal experience_bottle_collected(number:float)#吃到经验瓶时发出信号
func emit_increase_experience(number:float):#发射信号的函数这样写是为了控制经验瓶的经验多少
	experience_bottle_collected.emit(number*increase_percent)

signal blood_bottle_collected(number:float)
func emit_increase_blood(number:float):#发射信号的函数这样写是为了控制经验瓶的经验多少
	blood_bottle_collected.emit(number*increase_percent)

#能力升级信号，传出改变的能力和能力字典
signal ability_upgrade_add(upgrade:AbilityUpgrade,current_upgrade:Dictionary)

@export var upgrade_pool:Array[AbilityUpgrade]

func emit_ability_upgrade_add(upgrade:AbilityUpgrade,current_upgrade:Dictionary):
	await get_tree().process_frame
	ability_upgrade_add.emit(upgrade,current_upgrade)
	if upgrade.ID=="增强效果":
		increase_percent*=1.25


#用于在第一次攻击后启动音乐
var the_first=0
@warning_ignore("unused_signal")
signal the_first_damage()
#用于在player死后传输信号
@warning_ignore("unused_signal")
signal player_died
#暂停系统
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
	else :
		paused=0
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
var fix_right:=false :set=set_right

func set_fixed(value)->void:
	yaogan_fixed.emit(value)
	is_fixed=value

func set_right(value)->void:
	fix_right=value
	yaogan_fixed.emit(is_fixed)


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

## 选中难度模式（1=普通 2=困难 3=挑战），给主世界的难度切换物件用。
## 现在还没有 tag 选择界面，先按"该模式的 tag 全部选中"处理：
## 挑战模式把三个硬 tag 全开（时长加长 5 分钟 / 禁用能力 / 能力最多三次）。
func select_mode(index:int) -> void:
	if index==3:
		for key in hard_mode:
			hard_mode[key]=true
	mode_index=index          # 走 set_mode：会清掉不适用的 tag，并发出 mode_change
#挑战模式：1.游戏时长加长5分钟；2.减少一个自带能力；3.所有能力最多获得三次;
var hard_mode:Dictionary[HARD_MODE,Variant]={
	HARD_MODE.is_long:false,
	HARD_MODE.is_erase_ability:false,
	HARD_MODE.is_max_4:false,
}
#特殊事件
var is_co_disappear:=false
@warning_ignore("unused_signal")
signal collision_disappear
@warning_ignore("unused_signal")
signal collision_disappear_end

#成就计数
var special_moster_dead_number:=0
#光剑自动劈人
var is_light_auto:=true
