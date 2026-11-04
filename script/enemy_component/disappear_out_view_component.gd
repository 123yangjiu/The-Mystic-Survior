class_name DisappearOutViewComponent
extends EnemyComponent

@export var margin :int =50

var is_entered :=false

func _process(_delta: float) -> void:
	if is_entered:
		if ! is_in_rect():
			print("已删除")
			is_entered=false
			owner.queue_free()
	else :
		if is_in_rect():
			is_entered =true

func is_in_rect()->bool:
	#获取屏幕矩形
	var viewport_rect = get_viewport().get_visible_rect()
	var dead_zone = viewport_rect.grow(margin)
	
	var screen_pos = get_global_transform_with_canvas().origin
	
	if not dead_zone.has_point(screen_pos):
		return false
	else :
		return true
