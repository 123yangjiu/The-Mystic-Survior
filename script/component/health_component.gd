extends Node
class_name HealthComponent
@onready var animated_sprite_2d: AnimatedSprite2D = get_parent().get_node("AnimatedSprite2D")
#所有角色都可以公用这个组件，可以非常方便的计算伤害和调整数值
signal died
signal health_change
@export var max_health:float=10
var current_health
func _ready() -> void:
	current_health=max_health
func damage(_damage:float):
	current_health=max(current_health-_damage,0)
	health_change.emit()
	flash_white()
	if current_health==0:
		died.emit()
		owner.queue_free()
func get_health_persent():
	if current_health<=0:
		died.emit()
		return 0
	return min(current_health/max_health,1)

var 	_is_flashing=false
func flash_white(duration := 0.12):
	if _is_flashing:                       # ① 正在闪就直接返回
		return
	_is_flashing = true                    # ② 上锁

	var original = animated_sprite_2d.modulate
	animated_sprite_2d.modulate = Color.WHITE * 3
	await get_tree().create_timer(duration).timeout
	create_tween().tween_property(animated_sprite_2d, "modulate", original, 0.08)
	await get_tree().create_timer(0.08).timeout   # 等 tween 结束
	_is_flashing = false                            # ③ 解锁
	
	
