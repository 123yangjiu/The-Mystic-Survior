extends Node
@export var upgrade_pool :Array[AbilityUpgrade]
var can_chose_pool:Array[AbilityUpgrade]=[]#目前可供选择的池子
@export var experience_manager:Node
@export var upgrade_screen_scene:PackedScene
var upgrade_list: Array[AbilityUpgrade]#把抽中的三个能力放到一个列表中
var current_upgrade={}#一个字典存放当前所有的能力buff
var mystrious_pool:Array[AbilityUpgrade]=[]#放置已被选完4次的能力，给予很低的概率获取第5次
var mystrious_probality:=0.008
@export var inital_upgrade_export:Array[AbilityUpgrade]
var initial_upgrade:Array[AbilityUpgrade]
@export var initial_sort:String
var initial_number
func _ready():
	get_initial_upgrade("剑")
	get_initial_upgrade(initial_sort)
	inital_add_upgrade()
func on_level_up(_current_level:int):#升级时展示卡片
	pass

func inital_add_upgrade():
	for upgrade in initial_upgrade:
		add_upgrade(upgrade)
	pass

func get_initial_upgrade(sort:String,number:=3)->void:
	for upgrade in upgrade_pool:
		if upgrade.Sort == sort:
			for i in range(number):
				initial_upgrade.append(upgrade)
			
	pass

func add_upgrade(upgrade:AbilityUpgrade):#这个字典控制已经有的能力
	var has_upgrade=current_upgrade.has(upgrade.ID)
	var _has_Sort=current_upgrade.has(upgrade.Sort)
	if !has_upgrade:
		current_upgrade[upgrade.ID]={
			"Resource":upgrade,
			"quantity":1   #如果之前没有选过这种能力那把他加入字典
		}
	else:
		if current_upgrade[upgrade.ID]["quantity"]>2:
			for Upgrade in mystrious_pool:
				if Upgrade.ID==upgrade.ID:
					if !upgrade.ID=="火球力速":
						mystrious_pool.erase(Upgrade)
			for Upgrade in can_chose_pool:
				if Upgrade.ID==upgrade.ID:
					can_chose_pool.erase(Upgrade)
					mystrious_pool.append(Upgrade)
					print("已经删除",Upgrade.ID,"当前次数",current_upgrade[upgrade.ID]["quantity"])
					break
		current_upgrade[upgrade.ID]["quantity"]+=1#如果已经选过了就实现叠加把这个buff的数量加1
	if upgrade.ID=="解锁光剑":
		can_chose_pool = can_chose_pool.filter(func(op): return op.ID != "解锁光剑")
		#删掉解锁战锤      
		for upgrade_option in upgrade_pool:
			
			if upgrade_option.Sort=="光剑" and upgrade_option.ID!="解锁光剑":
				can_chose_pool.append(upgrade_option)
	if upgrade.ID=="解锁火球":
		can_chose_pool = can_chose_pool.filter(func(op): return op.ID != "解锁火球")
		#删掉解锁战锤      
		for upgrade_option in upgrade_pool:
			
			if upgrade_option.Sort=="火球" and upgrade_option.ID!="解锁火球":
				can_chose_pool.append(upgrade_option)
				
	if upgrade.ID=="解锁天堂之怒":
		can_chose_pool = can_chose_pool.filter(func(op): return op.ID != "解锁天堂之怒")
		#删掉解锁战锤      
		for upgrade_option in upgrade_pool:
			
			if upgrade_option.Sort=="天堂" and upgrade_option.ID!="解锁天堂之怒":
				can_chose_pool.append(upgrade_option)
	if upgrade.ID=="解锁法环":
		can_chose_pool = can_chose_pool.filter(func(op): return op.ID != "解锁法环")
		#删掉解锁战锤      
		for upgrade_option in upgrade_pool:
			
			if upgrade_option.Sort=="环" and upgrade_option.ID!="解锁法环":
				can_chose_pool.append(upgrade_option)
	GameEvent.emit_ability_upgrade_add(upgrade,current_upgrade)
	#print (current_upgrade)
	#print(can_chose_pool)

func on_upgrade_selected(upgrade):
	add_upgrade(upgrade)
	
	pass
