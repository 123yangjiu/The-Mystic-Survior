extends FlyThing
#方向和速度
#var direction:=Vector2(1.0,1.0)
#var speed =5
#穿透数量和伤害
#var amount :=1
#var damage :=5.0
func _ready() -> void:
	hitbox_component.area_entered.connect(on_area_enter)
	timer.timeout.connect(on_time_out)
func on_area_enter(area:Area2D):
	if area.is_in_group("enemy"):
		amount-=1
	if amount==0:
		queue_free()
func _physics_process(_delta: float) -> void:
	global_position+=direction*speed
func on_time_out()->void:
	queue_free()
