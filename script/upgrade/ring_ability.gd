extends Node2D
class_name Ring
@onready var hitbox_component: Area2D = $"hitbox component"
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
func _ready() -> void:
	animated_sprite_2d.animation_finished.connect(on_finish)
	pass
func _physics_process(_delta: float) -> void:
	var player=get_tree().get_first_node_in_group("player") as Node
	self.global_position=player.global_position
func on_finish():
	self.queue_free()
	print("动画播放结束")
