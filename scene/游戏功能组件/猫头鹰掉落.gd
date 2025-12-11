extends Node

@export_range(0,1) var drop_exprience_persent:float=0.7
@export_range(0,1) var drop_blood_persent:float=0.04
@export var drop_thing:Array[PackedScene]
@export var health_component:Node

func _ready() -> void:
    (health_component as HealthComponent).died.connect(on_died)
    GameEvent.ability_upgrade_add.connect(on_ability_upgrade_add)
func on_died():

    var entities_Layer=get_tree().get_first_node_in_group("实体图层")
    var spawn_position=(owner as Node2D).global_position
    for i in range(2):
        if randf()<drop_exprience_persent:
            var experience_thing_instance=drop_thing[0].instantiate() as Node2D
            call_deferred("add_bottle",entities_Layer,spawn_position,experience_thing_instance)
        if randf()<drop_blood_persent:
            var blood_thing_instance=drop_thing[1].instantiate() as Node2D
            call_deferred("add_bottle",entities_Layer,spawn_position,blood_thing_instance)
        if randf()<0.08:
            var bonus_thing_instance=drop_thing[2].instantiate() as Node2D
            call_deferred("add_bottle",entities_Layer,spawn_position,bonus_thing_instance)

func on_ability_upgrade_add(upgrade:AbilityUpgrade,_current_upgrade:Dictionary):
    #监听所有关于剑的升级
    if upgrade.ID=="增加生命瓶":
        drop_blood_persent+=drop_blood_persent
func add_bottle(entities_Layer:Node,spawn_position:Vector2,bottle_instance:Node2D):
    entities_Layer.add_child(bottle_instance)
    bottle_instance.global_position=spawn_position
