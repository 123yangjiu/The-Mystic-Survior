extends WoundComponent

var current_wound_degree:float

@onready var hurt_interval: Timer = $HurtInterval
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D

func set_else()->void:
	current_wound_degree=wound_degree

func wound_effect(damage:int)->void:
	if !hurt_interval.is_stopped():
		return
	#受伤效果
	health_component.on_damage(damage)
	flash_text(damage)
	flash_white()
	audio_stream_player_2d.play()
	hurt_interval.start()

func about_type()->void:
	area_2d.set_collision_layer_value(3,false)
	area_2d.set_collision_layer_value(2,true)
	match GameEvent.mode_index:
		0,1:
			wound_degree =0.5
		_:
			wound_degree=1.0

func _on_hurt_interval_timeout() -> void:
	if ! inside_area.is_empty():
		for area in inside_area:
			if area:
				if area.overlaps_area(area_2d):
					var component :AttackComponent= area.return_component()
					on_be_attacked (component.pass_damage())
				else :
					inside_area.erase(area)
