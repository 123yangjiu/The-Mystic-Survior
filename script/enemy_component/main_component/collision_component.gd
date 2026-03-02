class_name CollisionComponent
extends EnemyComponent

@export var collision_shape_2d:CollisionShape2D

var velocity_component:VelocityController
var ori_speed:float

func initial()->void:
	var _owner = owner as Enemy
	set_collision_layer()
	remove_child(collision_shape_2d)
	_owner.add_child(collision_shape_2d)
	GameEvent.collision_disappear.connect(on_collision_disappear)
	GameEvent.collision_disappear_end.connect(on_collision_disappear_end)
	if GameEvent.is_co_disappear:
		on_collision_disappear()

func set_collision_layer()->void:
	var _owner = owner as Enemy
	_owner.set_collision_layer_value(4,true)
	_owner.set_collision_mask_value(4,true)
	_owner.set_collision_mask_value(1,true)

func on_collision_disappear()->void:
	collision_shape_2d.disabled=true
	var _owner= owner as Enemy
	if _owner:
		for component in _owner.all_component:
			if component is VelocityController:
				velocity_component=component
				ori_speed = component.speed
				component.speed*=1.2

func on_collision_disappear_end()->void:
	var _owner = owner as Enemy
	var tween = create_tween()
	tween.tween_property(_owner.animated_sprite_2d,"modulate:a",1.0,0.5)
	collision_shape_2d.disabled=false
	if velocity_component and ori_speed:
		velocity_component.speed=ori_speed
