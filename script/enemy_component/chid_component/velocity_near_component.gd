extends VelocityController

var angle:float
var distance:float

func get_direction()->Vector2:
	var owner_2D=owner as Node2D
	var direction:Vector2
	direction=(GameEvent.play_global_position+Vector2.RIGHT.rotated(angle)*distance-owner_2D.global_position).normalized()
	return direction

func set_other()->void:
	angle = randf_range(0,TAU)
	distance = randf_range(speed,speed*1.5)
