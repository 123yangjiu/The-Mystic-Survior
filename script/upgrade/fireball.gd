extends Node2D
class_name Fireball
@onready var hitbox_component: Area2D = $"hitbox component"
var ammout=0#ammout是穿透次数

var velocity=0
var direction:Vector2
func _ready() -> void:
	hitbox_component.area_entered.connect(on_area_enter)
func _physics_process(_delta: float) -> void:
	var vec=direction*velocity
	self.global_position-=vec
func on_area_enter(area:Area2D):
	if area.is_in_group("enemy"):
		ammout-=1
	if ammout==0:
		queue_free()

func _on_timer_timeout() -> void:
	queue_free()
