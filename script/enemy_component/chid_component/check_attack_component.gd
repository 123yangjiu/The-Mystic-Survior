class_name CheckAttackComponent
extends AnimationAttackComponent

@export var check_collision:CollisionShape2D
@export var animation_player:AnimationPlayer

@onready var check_area: Area2D = $CheckArea
@onready var timer: Timer = $Timer

var is_player_in:=false

func set_other()->void:
	for node in get_children():
		if node == check_collision:
			var ori_global_position = check_collision.global_position
			remove_child(check_collision)
			check_area.add_child(check_collision)
			check_collision.global_position=ori_global_position

func _on_check_area_body_entered(body: Node2D) -> void:
	if ! body is Player or animation_player.is_playing() or ! timer.is_stopped():
		return
	is_player_in=true
	animation_player.play("attack")
	await animation_player.animation_finished
	timer.start()

func _on_check_area_body_exited(body: Node2D) -> void:
	if ! body is Player:
		return
	is_player_in=false

func _on_timer_timeout() -> void:
	if is_player_in:
		animation_player.play("attack")
		await animation_player.animation_finished
		timer.start()
	else :
		var _owner = owner as Enemy
		_owner.animated_sprite_2d.play("run")
