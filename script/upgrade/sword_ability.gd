extends Node2D
class_name Swordability
@onready var hitbox_component: HitboxComponent = $"hitbox component"
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D

#hitbox_component变成了Swordability的一种属性

func the_first_damage()->void:
    if GameEvent.the_first==0:
        GameEvent.the_first+=1
        GameEvent.the_first_damage.emit()
