class_name CopyComponent
extends EnemyComponent

@onready var area_2d: Area2D = $Copy

@export var collision_shape_2d: CollisionShape2D
@export_category("基础属性")
@export var gap_percent:=0.8
@export var number:=2
@export var angle :=PI/4
@export var distance:=30
var near_component =preload("uid://dedbm3f2745dw")

var is_copy:=false

func initial()->void:
	for node in get_children():
		if node == collision_shape_2d:
			var ori_global_position = collision_shape_2d.global_position
			remove_child(collision_shape_2d)
			area_2d.add_child(collision_shape_2d)
			collision_shape_2d.global_position=ori_global_position
	await get_tree().create_timer(0.05).timeout
	collision_shape_2d.disabled=false

func copy()->void:
	var n:=0
	for i in number:
		if owner:
			var another_self = owner.duplicate() as Enemy
			set_copy_object(another_self)
			another_self.global_position=_get_position(n)
			n+=1

func _get_position(i:=0)->Vector2:
	var _owner = owner as Node2D
	var direction = (_owner.global_position-GameEvent.play_global_position).normalized()
	var ready_position =direction*distance
	if i % 2==0:
		ready_position=ready_position.rotated(angle)
	else:
		ready_position=ready_position.rotated(-angle)
	ready_position +=_owner.global_position
	return ready_position

func _on_copy_body_entered(body: Node2D) -> void:
	if not body is Player or is_copy: 
		return
	is_copy=true
	call_deferred("copy")

func set_copy_object(another_self:Enemy)->void:
	var _owner = owner as Enemy
	var near_component_instance =near_component.instantiate() as VelocityController
	var enemy_player = get_tree().get_first_node_in_group("enemylayer")
	enemy_player.add_child(another_self)
	another_self.scale *=gap_percent
	if ! another_self.is_node_ready():
		await another_self.ready
	var self_velocity:VelocityController
	for self_component in _owner.all_component:
		if self_component is VelocityController:
			self_velocity=self_component
	for component:EnemyComponent in another_self.all_component:
		if component is CopyComponent:
			component.is_copy=true
		elif component is VelocityController:
			another_self.all_component.erase(component)
			another_self.remove_child(component) 
			another_self.add_child(near_component_instance)
			near_component_instance.owner = another_self
			near_component_instance.speed = self_velocity.speed*gap_percent
			near_component_instance.acceleration =self_velocity.acceleration*gap_percent
			near_component_instance.turn_rate = self_velocity.turn_rate*gap_percent
			near_component_instance.velocity =self_velocity.velocity*gap_percent
	another_self.health_component.max_health =_owner.health_component.max_health*gap_percent
