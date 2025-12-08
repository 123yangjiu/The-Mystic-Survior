extends CharacterBody2D

@onready var health_component: = $health_component
@onready var label: Label = $Label

#存放一串伤害和时间数据
var damage_record:Array[Vector2]
var one_turn_time :=3.0
var stop_time :=3.0
var _time :=0.0
var hurt:=false


func _ready() -> void:
	health_component.health_change.connect(change_label)
	pass

func _process(delta: float) -> void:
	if hurt:
		_time +=delta
		var damage_interval = damage_record[-1].y-damage_record[0].y
		if damage_interval>=one_turn_time:
			damage_record.remove_at(0)
		if _time-damage_record[-1].y>=stop_time:
			hurt=false
			damage_record.clear()

#显示DPS
func change_label(damage)->void:
	hurt= true
	damage_record.append(Vector2(damage,_time))
	if damage_record.size() >=2:
		var all_damage:=0.0
		var all_time = damage_record[-1].y-damage_record[0].y
		for i:Vector2 in damage_record:
			all_damage+= i.x
		var dps := "%.2f" %(all_damage/all_time)
		label.text= "DPS:"+dps
	else:
		label.text=str(damage)
