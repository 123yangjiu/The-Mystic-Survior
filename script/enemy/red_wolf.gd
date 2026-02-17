extends CharacterBody2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var health_component:HealthComponent = $health_component
@onready var velocity_component:Velocity_controller = $velocity_component
@export var is_left:=Vector2(1.0,1.0)
@export var _range:=40.0

func _physics_process(_delta: float) -> void:
	var owner_2D=self.global_position
	var direction=(GameEvent.play_global_position+is_left*_range-owner_2D).normalized()
	velocity_component.accelerate_to_direction(direction)
	velocity_component.move(self)
	if velocity.x<0:
		animated_sprite_2d.flip_h=true
	if velocity.x>0:
		animated_sprite_2d.flip_h=false
