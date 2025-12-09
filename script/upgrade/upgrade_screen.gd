extends CanvasLayer
signal upgrade_selected(upgrade:AbilityUpgrade)
@export var upgrade_card_scene:PackedScene
@onready var card_container: HBoxContainer = $MarginContainer/CardContainer
func _ready() -> void:
	get_tree().paused=true
	#暂停主场景树的时候这个显示屏节点也会被暂停所以在属性里面打开always总是运行这个节点
func Set_Ability_Upgrade(upgrades:Array[AbilityUpgrade]):#传入选项这个函数负责打印
	for upgrade in upgrades:
		var card_instance=upgrade_card_scene.instantiate()#实例化出一个节点
		card_container.add_child(card_instance)#把卡片实例挂到水平容器里面这样就可以水平显示
		card_instance.set_ability_upgrade(upgrade)#在卡片区的代码里面显示文本
		#这个set_abillity_upgrade函数是操控label的text的
		#而主函数Set_Ability_Upgrade本质上是传递升级选项的
		card_instance.selected.connect(on_upgrade_select.bind(upgrade))
		#绑定了升级的选项可以直接传进函数
	pass
func on_upgrade_select(upgrade:AbilityUpgrade):
	upgrade_selected.emit(upgrade)#把这个选项传出到其他地方，显示屏不负责
	#更改升级后的数值
	var children= get_parent().get_children()
	if children.size()>=2:
		return
	get_tree().paused=false
	#选择完能力之后游戏继续进行
	queue_free()#选择完能力之后关掉能力升级显示屏
	
	pass
