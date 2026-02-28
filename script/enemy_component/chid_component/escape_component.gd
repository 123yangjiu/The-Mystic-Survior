extends VelocityController

@export var max_distance:=40000.0

var ori_speed:float

var can_escape:=false

func set_other()->void:
	ori_speed=speed

func get_direction()->Vector2:
	var direction = get_player_direction()
	if can_escape:
		direction *=-1
	return direction

func get_player_direction()->Vector2:
	var owner_2D=owner as Node2D
	var direction:Vector2=GameEvent.play_global_position-owner_2D.global_position
	var length =direction.length_squared()
	if length < 5000.0:
		can_escape=true
	if length>max_distance:
		var slow_percent = clamp(0.8-(max_distance-40000.0)/100000.0,0,0.8) 
		speed= ori_speed*slow_percent
	else:
		speed=ori_speed
	direction=direction.normalized()
	return direction
