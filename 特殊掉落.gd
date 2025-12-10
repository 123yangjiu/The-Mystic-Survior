extends Node

@export_range(0,1) var drop_persent:float=0.5
@export_range(0,1) var drop_blood_persent:float=0.3
@export var drop_thing:Array[PackedScene]
@export var health_component:Node
var random_R=randf_range(100,150)
var bonus_drop
func _ready() -> void:
	health_component.died.connect(on_died)
func on_died():
	var bonus_botlle:=0
	for i in range(5):
		var angle := TAU * i / 3
		var entities_Layer=get_tree().get_first_node_in_group("实体图层")
		var spawn_position=(owner as Node2D).global_position
		var bottle_instence:Node2D
		if randf()<drop_persent:
			#普通经验瓶
			bottle_instence=drop_thing[0].instantiate() as Node2D
			call_deferred("add_bottle",entities_Layer,spawn_position,angle,bottle_instence)
			if randf()<drop_blood_persent:
				bottle_instence=drop_thing[1].instantiate() as Node2D
			else:
				bonus_botlle +=1
				bottle_instence=drop_thing[2].instantiate() as Node2D
			call_deferred("add_bottle",entities_Layer,spawn_position,angle,bottle_instence)
		if i==4 and bonus_botlle==0:
			bottle_instence=drop_thing[2].instantiate() as Node2D
			call_deferred("add_bottle",entities_Layer,spawn_position,angle,bottle_instence)

func add_bottle(entities_Layer:Node,spawn_position:Vector2,angle,bottle_instance:Node2D):
	if ! bottle_instance:
		return
	entities_Layer.add_child(bottle_instance)
	bottle_instance.global_position=spawn_position+Vector2.RIGHT.rotated(angle) *float(random_R)
