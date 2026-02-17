class_name DropComment
extends Node

@export var drop_thingandpersent:Dictionary[PackedScene,float]={
	preload("uid://i5imcyd15vix"):0.7,
	preload("uid://daaqcmminiyk1"):0.04,
	preload("uid://f15fc5ggcq0l"):0.0
}
@export var drop_range :=1
@export var health_component:Node
var all_dropthing:Array
var all_droppresent:Array

func _ready() -> void:
	(health_component as HealthComponent).died.connect(on_died)
	#GameEvent.ability_upgrade_add.connect(on_ability_upgrade_add)
	for i in drop_thingandpersent.keys():
		all_dropthing.append(i)
		all_droppresent.append(drop_thingandpersent[i])

func on_died():
	var entities_Layer=get_tree().get_first_node_in_group("实体图层")
	for i in drop_range:
		for index in all_dropthing.size():
			if randf()<all_droppresent[index]:
				var drop_instance=all_dropthing[index].instantiate() as Node2D
				call_deferred("add_bottle",entities_Layer,get_position(index),drop_instance)

func add_bottle(entities_Layer:Node,spawn_position:Vector2,bottle_instance:Node2D):
	entities_Layer.add_child(bottle_instance)
	bottle_instance.global_position=spawn_position

func get_position(index=0):
	if index==0:
		return (owner as Node2D).global_position
	else:
		var angle :float= TAU*index / 3.0
		var random_R=get_rangR()
		return (owner as Node2D).global_position+Vector2.RIGHT.rotated(angle) *float(random_R)

func get_rangR():
	return randf_range(5,10)
