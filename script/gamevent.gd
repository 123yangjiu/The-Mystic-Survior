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
