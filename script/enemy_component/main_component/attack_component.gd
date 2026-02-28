class_name AttackComponent
extends EnemyComponent

enum TYPE{
	enemy,
	ability
}
@onready var area_2d: AreaInComponent = $Area2D
@export var collision_shape_2d: CollisionShape2D
@export_category("基础属性")
@export var damage:=10.0
@export_category("给谁用的")
@export var type:=TYPE.enemy

var damage_range:=1.0

func initial()->void:
	for node in get_children():
		if node == collision_shape_2d:
			var ori_global_position = collision_shape_2d.global_position
			remove_child(collision_shape_2d)
			area_2d.add_child(collision_shape_2d)
			collision_shape_2d.global_position=ori_global_position
	match type:
		TYPE.enemy:
			area_2d.set_collision_mask_value(2,true)
			area_2d.set_collision_mask_value(3,false)
		TYPE.ability:
			match GameEvent.mode_index:
				2,3:
					damage_range =0.9
				_:
					pass
			area_2d.set_collision_mask_value(3,true)
			area_2d.set_collision_mask_value(2,false)
	set_other()

func set_other()->void:
	pass

func pass_damage()->float:
	var real_damage = damage*damage_range
	real_damage += randf_range(-real_damage/9.0,real_damage/9.0)
	return real_damage

func _on_area_2d_area_entered(area:Area2D) -> void:
	if ! area is AreaInComponent:
		return
	var _area = area as AreaInComponent
	var component := _area.return_component()
	if component.owner == owner:
		return
	if ! component is WoundComponent:
		return
	var _component = component as WoundComponent
	_component.inside_area.append(area_2d)
	_component.on_be_attacked(pass_damage())
	match type:
		TYPE.enemy:
			var _owner =owner as Enemy
			for velocity_component in _owner.all_component:
				if velocity_component is VelocityController:
					var ori_rate = velocity_component.turn_rate
					velocity_component.turn_rate =0.0
					await get_tree().create_timer(0.5).timeout
					if velocity_component:
						if velocity_component.turn_rate < ori_rate:
							velocity_component.turn_rate = ori_rate
		TYPE.ability:
			pass
