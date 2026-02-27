extends CollisionComponent

@export var layer:int=4

func set_collision_layer()->void:
	var _owner = owner as Enemy
	_owner.set_collision_layer_value(layer,true)
	_owner.set_collision_mask_value(layer,false)
	_owner.set_collision_mask_value(1,true)
