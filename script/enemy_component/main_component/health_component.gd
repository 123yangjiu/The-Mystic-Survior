extends EnemyComponent
class_name HealthComponent
signal died
signal health_change
@export var max_health:float=10 :set =set_max_health
var current_health:float :set=set_current_health

func initial()->void:
	current_health=max_health

func on_damage(damage:int):
	current_health-=damage

func get_health_persent():
	return min(current_health/max_health,1)

func set_max_health(value)->void:
	if current_health==0:
		max_health=value
		return
	if value >max_health:
		var percent = value/max_health
		max_health=value
		current_health = percent*current_health
	elif value < current_health:
		max_health=value
		current_health=value
	else :
		max_health=value

func set_current_health(value)->void:
	current_health= clamp(value,0,max_health)
	health_change.emit()
	if current_health==0:
		died.emit()
		owner.queue_free()
