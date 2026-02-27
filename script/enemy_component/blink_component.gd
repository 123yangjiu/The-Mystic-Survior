class_name BlinkComponent
extends EnemyComponent

@export var animation_sprite:AnimatedSprite2D
@export var collision_shape:CollisionShape2D
@onready var area_2d: Area2D = $Area2D


@onready var blink_interval: Timer = $BlinkInterval

@export_category("基础属性")
@export var interval_time:=1.0
@export var distance:=80

var ready_time:=0.0


func initial()->void:
	blink_interval.wait_time=interval_time
	var _owner = owner as Enemy
	if ! _owner.is_node_ready():
		await _owner.ready
	var ori_global_position = collision_shape.global_position
	remove_child(collision_shape)
	area_2d.add_child(collision_shape)
	collision_shape.global_position=ori_global_position


func _on_blink_interval_timeout() -> void:
	ready_time=0.0
	if animation_sprite:
		animation_sprite.play("blink")
	var _owner = owner as Enemy
	var this_animation = _owner.animated_sprite_2d as AnimatedSprite2D
	var tween = create_tween()
	tween.tween_property(this_animation,"modulate:a",0,1.0)
	await tween.finished
	var new_tween = create_tween()
	_owner.global_position=final_position()
	new_tween.tween_property(this_animation,"modulate:a",1.0,1.0)
	

func final_position()->Vector2:
	var blink_position:Vector2
	if GameEvent.play_right:
		blink_position = GameEvent.play_global_position+Vector2.LEFT*distance
	else :
		blink_position = GameEvent.play_global_position+Vector2.RIGHT*distance
	return blink_position

func _on_area_2d_body_entered(body: Node2D) -> void:
	if ! body is Player:
		return
	blink_interval.start(ready_time)

func _on_area_2d_body_exited(body: Node2D) -> void:
	if ! body is Player:
		return
	ready_time = blink_interval.wait_time-blink_interval.time_left
