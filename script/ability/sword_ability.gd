extends FlyThing
class_name Sword
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var end: Node2D = $End


func the_first_damage()->void:
	if GameEvent.the_first==0:
		GameEvent.the_first+=1
		GameEvent.the_first_damage.emit()

func on_area_enter(_area:Area2D):
	pass

func _physics_process(_delta: float) -> void:
	pass
