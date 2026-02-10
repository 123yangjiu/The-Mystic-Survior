extends CharacterBody2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var health_component:HealthComponent = $health_component
@onready var velocity_component:Velocity_controller = $velocity_component

func _physics_process(_delta: float) -> void:
	var owner_2D=self.global_position
	var direction=(GameEvent.play_global_position-owner_2D).normalized()
	velocity_component.accelerate_to_direction(-direction)
	velocity_component.move(self)
	if velocity.x<0:
		animated_sprite_2d.flip_h=true
	if velocity.x>0:
		animated_sprite_2d.flip_h=false
