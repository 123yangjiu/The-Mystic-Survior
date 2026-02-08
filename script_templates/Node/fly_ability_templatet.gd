extends FlyThing

#起始变量起始方向和速度
#穿透数量和伤害

func _ready() -> void:
	if hitbox_component:
		hitbox_component.area_entered.connect(on_area_enter)
	if timer:
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
