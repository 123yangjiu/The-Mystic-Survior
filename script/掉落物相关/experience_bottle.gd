extends Node2D
func _ready():
   
	$Area2D.area_entered.connect(on_area_entered)
func tween_collect(persent:float,start_position:Vector2):
	global_position=start_position.lerp(GameEvent.play_global_position,persent)

func collect():
	GameEvent.emit_increase_experience(1)
	queue_free()
func on_area_entered(_other_area:Area2D):

	var tween=create_tween()
	tween.tween_method(tween_collect.bind(global_position),0.0,1.0,.3).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	
	tween.tween_callback(collect)
	


	
	
