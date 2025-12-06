extends Node2D
func _ready():
   
	$Area2D.area_entered.connect(on_area_entered)
func on_area_entered(_other_area:Area2D):
	GameEvent.emit_increase_blood(30)
	
	queue_free()
