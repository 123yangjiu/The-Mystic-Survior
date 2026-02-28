extends CanvasLayer

@onready var grid_container: GridContainer = $GridContainer

@export var upgrade_card_scene:PackedScene
func _ready() -> void:
	Set_Ability_Upgrade(GameEvent.upgrade_pool)

func Set_Ability_Upgrade(upgrades:Array[AbilityUpgrade]):#传入选项这个函数负责打印
	var n:=0.0
	for upgrade in upgrades:
		if upgrade.Sort =="角色能力":
			n+=1
			var card_instance:=upgrade_card_scene.instantiate()#实例化出一个节点
			grid_container.add_child(card_instance)#把卡片实例挂到水平容器里面这样就可以水平显示
			card_instance.set_ability_upgrade(upgrade)#在卡片区的代码里面显示文本
			card_instance.free_object=self
	grid_container.columns=int(n/2)+1
