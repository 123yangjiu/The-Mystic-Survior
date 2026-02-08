extends Node
@onready var difficulty_timer: Timer = $difficulty_timer

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

#限制出怪量
var current_monster :=0.0

#简单模式：1.怪物移速下降10%；2.刷怪速度下降很多；3.玩家伤害提高10%;4.玩家受伤减少1半
var is_hard:=false

var play_global_position:=Vector2(0,0)
