extends Node2D
class_name Swordability
@onready var hitbox_component: HitboxComponent = $"hitbox component"
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var collision_shape_2d_2: CollisionShape2D = $"hitbox component/CollisionShape2D2"

#hitbox_component变成了Swordability的一种属性

func the_first_damage()->void:
	if GameEvent.the_first==0:
		GameEvent.the_first+=1
		GameEvent.the_first_damage.emit()



func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	self.queue_free()
	pass # Replace with function body.
