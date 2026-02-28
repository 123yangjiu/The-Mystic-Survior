extends Node
@export var upgrade_pool :Array[AbilityUpgrade]
var can_chose_pool:Array[AbilityUpgrade]=[]#目前可供选择的池子
var no_chose_pool:Array[AbilityUpgrade]=[]#目前不可选择的池子
@export var experience_manager:Node
@export var upgrade_screen_scene:PackedScene
var upgrade_list: Array[AbilityUpgrade]#把抽中的三个能力放到一个列表中
var current_upgrade={}#一个字典存放当前所有的能力buff
var mystrious_pool:Array[AbilityUpgrade]=[]#放置已被选完4次的能力，给予很低的概率获取第5次
var mystrious_probality:=0.02
var limit_int:=3

var initial_upgrade:AbilityUpgrade

func _ready():
	upgrade_pool=GameEvent.upgrade_pool
	experience_manager.level_up.connect(on_level_up)
	var unlock_pool:Array[AbilityUpgrade]
	for ability in upgrade_pool:
		if ability.is_init:
			if ability.is_unlock:
				unlock_pool.append(ability)
			else:
				can_chose_pool.append(ability)
		if ability==upgrade_pool[-1]:
			unlock_pool.shuffle()
			for i in unlock_pool.slice(0,4):
				can_chose_pool.append(i)
		#初始化选择池子,选择剑类的选项和所有解锁新武器的选项
	#设置困难和简单模式
	if GameEvent.easy_mode[GameEvent.EASY_MODE.is_initial]:
		initial_upgrade=GameEvent.easy_mode[GameEvent.EASY_MODE.is_initial]
		add_upgrade(initial_upgrade)
	if GameEvent.hard_mode[GameEvent.HARD_MODE.is_max_4]:
		limit_int=2
	if GameEvent.easy_mode[GameEvent.EASY_MODE.is_ascend]:
		for ability in can_chose_pool:
			if ability.Sort=="角色能力":
				add_upgrade(ability)
	if GameEvent.hard_mode[GameEvent.HARD_MODE.is_erase_ability]:
		can_chose_pool.erase(GameEvent.hard_mode[GameEvent.HARD_MODE.is_erase_ability])

func on_level_up(_current_level:int):#升级时展示卡片
	upgrade_list.clear() 
	while upgrade_list.size()<3: #让获得同一种能力五次非常困难
		if randf()<=mystrious_probality and mystrious_pool.size() !=0:
			var chosen_upgrade=mystrious_pool.pick_random()
			if not chosen_upgrade in upgrade_list:
				upgrade_list.append(chosen_upgrade)
			#转换成数组属性Array[AbillityUpgrade]
			if chosen_upgrade==null:
				return
		else:
			var chosen_upgrade=can_chose_pool.pick_random() as AbilityUpgrade#升级选项是从
			#升级选项池子中随机抽取一个
			if not chosen_upgrade in upgrade_list:
				upgrade_list.append(chosen_upgrade)
			
			#转换成数组属性Array[AbillityUpgrade]
			if chosen_upgrade==null:
				return
	var  upgrade_screen_instance=upgrade_screen_scene.instantiate()
	add_child(upgrade_screen_instance)#把显示屏幕场景的实例加到节点树上
	upgrade_screen_instance.Set_Ability_Upgrade(upgrade_list)#升级选项显示屏显示卡片
	upgrade_screen_instance.upgrade_selected.connect(add_upgrade)

func add_upgrade(upgrade:AbilityUpgrade):#这个字典控制已经有的能力
	var has_upgrade=current_upgrade.has(upgrade.ID)
	var _has_Sort=current_upgrade.has(upgrade.Sort)
	if !has_upgrade:
		current_upgrade[upgrade.ID]={
			"Resource":upgrade,
			"quantity":1   #如果之前没有选过这种能力那把他加入字典
		}
	else:
		#选到3次的能力加入神秘池子
		if current_upgrade[upgrade.ID]["quantity"]>1:
			#再次从神秘池子选到的能力去除
			if current_upgrade[upgrade.ID]["quantity"]>limit_int:
				for Upgrade in mystrious_pool:
					if Upgrade.ID==upgrade.ID:
						mystrious_pool.erase(Upgrade)
			for Upgrade in can_chose_pool:
				if Upgrade.ID==upgrade.ID:
					can_chose_pool.erase(Upgrade)
					mystrious_pool.append(Upgrade)
					break
		#如果已经选过了就实现叠加把这个buff的数量加1
		current_upgrade[upgrade.ID]["quantity"]+=1
	#检测是否是解锁类型的，然后删除这个能力，加入其他加强能力
	if upgrade.is_unlock:
		can_chose_pool.erase(upgrade)
		for _upgrade in upgrade_pool:
			if _upgrade.Sort == upgrade.Sort and _upgrade.ID != upgrade.ID:
				can_chose_pool.append(_upgrade)
	#检测这个能力是不是只能点一次
	if upgrade.lock_code!=0:
		for ability in no_chose_pool:
			if ability.self_lock ==upgrade.lock_code:
				no_chose_pool.erase(ability)
				can_chose_pool.append(ability)
	if upgrade.self_lock!=0:
		can_chose_pool.erase(upgrade)
		no_chose_pool.append(upgrade)
	GameEvent.emit_ability_upgrade_add(upgrade,current_upgrade)

func on_upgrade_selected(upgrade):
	add_upgrade(upgrade)
