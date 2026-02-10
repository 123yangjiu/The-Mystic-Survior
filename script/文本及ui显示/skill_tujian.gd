extends CanvasLayer

@export var upgrade_card_scene:PackedScene
@onready var h_box_container: HBoxContainer = $ScrollContainer/VBoxContainer/HBoxContainer
@onready var h_box_container_2: HBoxContainer = $ScrollContainer/VBoxContainer/HBoxContainer2
@export var all_upgrade:Array[AbilityUpgrade]

func _ready() -> void:
	Set_Ability_Upgrade(all_upgrade)

func Set_Ability_Upgrade(upgrades:Array[AbilityUpgrade]):#传入选项这个函数负责打印
	var n:=0
	var current_number :=0
	for upgrade in upgrades:
		current_number+=1
		var card_instance:AbilityCard=upgrade_card_scene.instantiate()#实例化出一个节点
		h_box_container.add_child(card_instance)#把卡片实例挂到水平容器里面这样就可以水平显示
		card_instance.set_ability_upgrade(upgrade)#在卡片区的代码里面显示文本
		if upgrade.ID =="剑的伤害":
			h_box_container_2.get_child(n).global_position = card_instance.global_position+Vector2(120+120*current_number,80)
			n+=1
		elif upgrade.is_unlock==true:
			h_box_container_2.get_child(n).global_position = card_instance.global_position+Vector2(120+120*current_number,80)
			n+=1
