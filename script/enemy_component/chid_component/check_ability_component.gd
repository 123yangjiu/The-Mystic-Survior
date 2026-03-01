class_name CheckAbilityComponent
extends EnemyComponent

@export var check_collision:CollisionShape2D
@export var ability:PackedScene
@export var re_attack_time:=3.0
@export var need_prepare:=false
@onready var check_area: Area2D = $CheckArea
@onready var timer: Timer = $Timer

var animate_sprite_2d:AnimatedSprite2D
var is_player_in:=false

func initial()->void:
	timer.wait_time = re_attack_time
	for node in get_children():
		if node == check_collision:
			var ori_global_position = check_collision.global_position
			remove_child(check_collision)
			check_area.add_child(check_collision)
			check_collision.global_position=ori_global_position
	var _owner = owner as Enemy
	if ! _owner.is_node_ready():
		await _owner.ready
	animate_sprite_2d=_owner.animated_sprite_2d

func _on_check_area_body_entered(body: Node2D) -> void:
	if ! body is Player:
		return
	is_player_in=true
	if ! timer.is_stopped():
		return
	attack()
	timer.start()

func _on_check_area_body_exited(body: Node2D) -> void:
	if ! body is Player:
		return
	is_player_in=false

func _on_timer_timeout() -> void:
	if is_player_in:
		attack()
		timer.start()
	else :
		pass

func attack()->void:
	animate_sprite_2d.play("shoot")
	var ability_instance = ability.instantiate() as EnemyAbility
	ability_instance.enemy = animate_sprite_2d
	ability_instance.component =self
	add_child(ability_instance)
	if need_prepare:
		return
	ability_instance.direction=(GameEvent.play_global_position-self.global_position).normalized()
	ability_instance.rotation = ability_instance.direction.angle()
