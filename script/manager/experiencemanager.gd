extends Node
signal experience_updated(currrent_experience:float,taget_experience:float)
signal level_up(new_level:int)
var current_experience=0
var current_level=1
var target_experience=4
var experience_gap=7
func _ready():
	GameEvent.experience_bottle_collected.connect(on_experience_collect)
	#当捡到经验瓶的信号发出的时候链接触发经验增长函数的函数ss
func increase_experience(number:float):#经验增长的函数
	current_experience=min(current_experience+number,target_experience)
	experience_updated.emit(current_experience,target_experience)#用信号拿到当前
	#经验和当前等级升级所需要的经验
	if current_experience==target_experience:#判定是否升级
		current_level+=1
		var _t=current_level-1
		target_experience+=experience_gap
	   
		#设置经验条上限
		experience_gap+=3
		current_experience=0
		experience_updated.emit(current_experience,target_experience)
		level_up.emit(current_level)#升级时发送当前等级
	
func on_experience_collect(number:float):#触发经验增长函数的函数
	increase_experience(number)#当捡到瓶子的时候经验增长
