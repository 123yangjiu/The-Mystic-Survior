class_name DropComment
extends EnemyComponent

@export var drop_thingandpersent:Dictionary[PackedScene,float]={
	preload("uid://i5imcyd15vix"):0.7,
	preload("uid://daaqcmminiyk1"):0.04,
	preload("uid://f15fc5ggcq0l"):0.0
}
@export var drop_range :=1
var all_dropthing:Array
var all_droppresent:Array


func initial()->void:
	for i in drop_thingandpersent.keys():
		all_dropthing.append(i)
		all_droppresent.append(drop_thingandpersent[i])
	for component in owner.all_component:
		if component is HealthComponent:
			var health_component:HealthComponent=component
			health_component.died.connect(on_died)

func on_died():
	var entities_Layer=get_tree().get_first_node_in_group("实体图层")
	for i in drop_range:
		for index in all_dropthing.size():
			if randf()<all_droppresent[index]*GameEvent.increase_percent:
				var drop_instance=all_dropthing[index].instantiate() as Node2D
				call_deferred("add_bottle",entities_Layer,_get_position(index,i),drop_instance)

func add_bottle(entities_Layer:Node,spawn_position:Vector2,bottle_instance:Node2D):
	entities_Layer.add_child(bottle_instance)
	bottle_instance.global_position=spawn_position

func _get_position(index:int,i:int):
	if index==0:
		return (owner as Node2D).global_position
	else:
		var angle :float= TAU*index / all_dropthing.size()
		var random_R=get_rangR(i)
		return (owner as Node2D).global_position+Vector2.RIGHT.rotated(angle) *float(random_R)

func get_rangR(i:int):
	return randf_range(20+i*10,50+i*40)
