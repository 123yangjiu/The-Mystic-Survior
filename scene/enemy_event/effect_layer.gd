class_name EffectManager
extends CanvasLayer

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var begin: Node2D = $Begin
@onready var end: Node2D = $End

func _ready() -> void:
	GameEvent.collision_disappear.connect(on_collision_disappear)

func on_collision_disappear()->void:
	audio_stream_player.play()
	#animated_sprite_2d.visible=true
	#animated_sprite_2d.play("wolf")
	#animated_sprite_2d.global_position = begin.global_position
	#var tween = create_tween().set_ease(Tween.EASE_OUT_IN)
	#tween.tween_property(animated_sprite_2d,"global_position:x",end.global_position.x,2.5)
