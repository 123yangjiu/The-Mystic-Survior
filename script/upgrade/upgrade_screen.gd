extends CanvasLayer
signal upgrade_selected(upgrade:AbilityUpgrade)
@export var upgrade_card_scene:PackedScene
@onready var card_container: HBoxContainer = $MarginContainer/CardContainer
@export var stop_screen:PackedScene
var ready_ability:AbilityUpgrade
var ready_card:AbilityCard
var all_card:Array[AbilityCard]

func _ready() -> void:
	GameEvent.paused+=1
	get_tree().paused=true
	ready_ability=null
	all_card.clear()
	#暂停主场景树的时候这个显示屏节点也会被暂停所以在属性里面打开always总是运行这个节点
func Set_Ability_Upgrade(upgrades:Array[AbilityUpgrade]):#传入选项这个函数负责打印
	var n=0 #用于确认中间的卡片
	for upgrade in upgrades:
		var card_instance:AbilityCard=upgrade_card_scene.instantiate()#实例化出一个节点
		card_container.add_child(card_instance)#把卡片实例挂到水平容器里面这样就可以水平显示
		card_instance.set_ability_upgrade(upgrade)#在卡片区的代码里面显示文本
		all_card.append(card_instance)
		#这个set_abillity_upgrade函数是操控label的text的
		#而主函数Set_Ability_Upgrade本质上是传递升级选项的
		card_instance.selected.connect(on_upgrade_select.bind(upgrade,card_instance))
		card_instance.in_ready.connect(on_upgrade_ready.bind(upgrade,card_instance))
		card_instance.no_ready.connect(on_upgrade_no_ready.bind(upgrade,card_instance))
		#绑定了升级的选项可以直接传进函数
		n+=1
		if n==2:
			card_instance._on_texture_rect_mouse_entered()
			ready_ability = upgrade
			ready_card=card_instance


func on_upgrade_select(upgrade:AbilityUpgrade,_card:AbilityCard):
    upgrade_selected.emit(upgrade)#把这个选项传出到其他地方，显示屏不负责
    #更改升级后的数值
    var children= get_parent().get_children()
    if children.size()>=2:
        return
    if GameEvent.paused>0:
        GameEvent.paused-=1
        if GameEvent.paused==0:
            get_tree().paused=false
    #选择完能力之后游戏继续进行
    queue_free()#选择完能力之后关掉能力升级显示屏


func on_upgrade_ready(upgrade:AbilityUpgrade,card:AbilityCard)->void:
	if ready_card and ready_card!=card:
		ready_card._on_texture_rect_mouse_exited()
	ready_ability=upgrade
	ready_card=card

func on_upgrade_no_ready(upgrade:AbilityUpgrade,card:AbilityCard)->void:
	if ready_ability==upgrade:
		ready_ability=null
	if ready_card==card:
		ready_card=null


func _input(event: InputEvent) -> void:


	if event.is_action_released("暂停"):
		GameEvent.paused+=1
		get_viewport().set_input_as_handled()
		GameEvent.game_stop.emit()
		var screen=stop_screen.instantiate()
		add_child(screen)
	elif event.is_action_released("left"):
		if !ready_card:
			ready_card=all_card.get(1)
		var _index := all_card.find(ready_card)-1
		if _index <0:
			_index = all_card.size()+_index
		var new_card = all_card.get(_index)
		ready_card._on_texture_rect_mouse_exited()
		new_card._on_texture_rect_mouse_entered()
	elif event.is_action_released("right"):
		if !ready_card:
			ready_card=all_card.get(1)
		var _index := all_card.find(ready_card)+1
		if _index >all_card.size()-1:
			_index-=all_card.size()
		var new_card = all_card.get(_index)
		ready_card._on_texture_rect_mouse_exited()
		new_card._on_texture_rect_mouse_entered()
	elif event.is_action_pressed("confirm"):
		on_upgrade_select(ready_ability,null)
	

