extends Node
@export var drop_thing:PackedScene
@export var health_component:Node
var drop_persent:=0.2
func _ready() -> void:
	(health_component as HealthComponent).died.connect(on_died)
func on_died():#石头人死亡掉落绿瓶子
	GameEvent.current_monster-=1
	var entities_Layer=get_tree().get_first_node_in_group("实体图层")
	var spawn_position=(owner as Node2D).global_position
	var drop_thing_instance=drop_thing.instantiate() as Node2D
	if randf()<0.25:
		call_deferred("add_bottle",entities_Layer,spawn_position,drop_thing_instance)

func add_bottle(entities_Layer:Node,spawn_position:Vector2,bottle_instance:Node2D):
	entities_Layer.add_child(bottle_instance)
	bottle_instance.global_position=spawn_position
	
