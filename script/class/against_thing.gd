class_name AgainstThing
extends Node2D

#伤害
@export var hitbox_component:Area2D
@export var animation_player:AnimationPlayer

#func _ready() -> void:
	#animation_player.animation_finished.connect(on_animation_finished)
#
#func on_animation_finished(_name)->void:
	#self.queue_free()
