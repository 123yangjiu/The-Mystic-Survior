class_name CheckAttackComponent
extends AnimationAttackComponent

@export var check_collision:CollisionShape2D
@export var animation_player:AnimationPlayer

@export var re_attack_time:=1.0
@onready var check_area: Area2D = $CheckArea
@onready var timer: Timer = $Timer

var is_player_in:=false

func set_other()->void:
	timer.wait_time = re_attack_time
	for node in get_children():
		if node == check_collision:
			var ori_global_position = check_collision.global_position
			remove_child(check_collision)
			check_area.add_child(check_collision)
			check_collision.global_position=ori_global_position

func _on_check_area_body_entered(body: Node2D) -> void:
	if ! body is Player:
		return
	is_player_in=true
	if ! timer.is_stopped() or animation_player.is_playing():
		return
	await get_tree().create_timer(0.5,false).timeout
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
