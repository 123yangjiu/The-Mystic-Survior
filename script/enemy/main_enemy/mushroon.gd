extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var health_component: HealthComponent = $health_component
@onready var velocity_component: Node = $velocity_component

func _physics_process(delta: float) -> void:
	# ✅ 调用velocity_component
	velocity_component.accelerate_to_player()
	velocity_component.move(self, delta)  # ✅ 传递delta参数
	
	# ✅ 动画翻转（添加阈值避免抖动）
	if velocity.x < -5:  # 阈值设为5像素/秒
		animated_sprite_2d.flip_h = true
	elif velocity.x > 5:
		animated_sprite_2d.flip_h = false
	
	# ❌ 删除这行！velocity_component.move()中已调用过move_and_slide()
	# move_and_slide()  # 重要：删除这行，避免重复调用

func get_player_position():
	var player = get_tree().get_first_node_in_group("player")
	if player:
		return (player.global_position - global_position).normalized()
	return Vector2.ZERO

func _on_timer_timeout() -> void:
	self.queue_free()
