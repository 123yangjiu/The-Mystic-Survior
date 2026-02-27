class_name SummonComponent
extends EnemyComponent

enum TYPE{
	near_player,
	near_self,
	rangf
}

@onready var spawn_interval: Timer = $spawn_interval
@onready var area_2d: Area2D = $Area2D
@export var collision_shape:CollisionShape2D


@export_category("基础属性")
@export var summon_enemy:PackedScene
@export var summon_type:=TYPE.near_player
@export var summon_number:=2
@export var spawn_r:=80.0

var can_summon:=false

func initial()->void:
	var ori_global_position = collision_shape.global_position
	remove_child(collision_shape)
	area_2d.add_child(collision_shape)
	collision_shape.global_position=ori_global_position

func _on_spawn_interval_timeout() -> void:
	summon()

func summon()->void:
	if ! can_summon:
		return
	for i in summon_number:
		var enemy_instance = summon_enemy.instantiate() as Enemy
		var enemy_layer = get_tree().get_first_node_in_group("enemylayer")
		var enemy_position:Vector2
		match summon_type:
			TYPE.near_player:
				enemy_position = GameEvent.play_global_position+Vector2(randfn(0.8,0.1),0).rotated(randf_range(0,TAU))*spawn_r
			TYPE.near_self:
				var _owner=owner as Enemy
				enemy_position = _owner.global_position+Vector2(randfn(0.8,0.1),0).rotated(randf_range(0,TAU))*spawn_r
			_:
				var _owner=owner as Enemy
				enemy_position = _owner.global_position+Vector2(randfn(0.8,0.1),0).rotated(randf_range(0,TAU))*spawn_r
		enemy_layer.add_child(enemy_instance)
		enemy_instance.global_position = enemy_position


func _on_area_2d_body_entered(body: Node2D) -> void:
	if ! body is Player:
		return
	print("要开始l")
	can_summon=true
	spawn_interval.start()

func _on_area_2d_body_exited(body: Node2D) -> void:
	if ! body is Player:
		return
	can_summon=false
