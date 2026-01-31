extends CanvasLayer

@export var upgrade_card_scene:PackedScene
@onready var h_box_container: HBoxContainer = $ScrollContainer/HBoxContainer

@export var all_upgrade:Array[AbilityUpgrade]

func _ready() -> void:
	Set_Ability_Upgrade(all_upgrade)

func Set_Ability_Upgrade(upgrades:Array[AbilityUpgrade]):#传入选项这个函数负责打印
	for upgrade in upgrades:
		var card_instance:AbilityCard=upgrade_card_scene.instantiate()#实例化出一个节点
		h_box_container.add_child(card_instance)#把卡片实例挂到水平容器里面这样就可以水平显示
		card_instance.set_ability_upgrade(upgrade)#在卡片区的代码里面显示文本
		#这个set_abillity_upgrade函数是操控label的text的
		#而主函数Set_Ability_Upgrade本质上是传递升级选项的
