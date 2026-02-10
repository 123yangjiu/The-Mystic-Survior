extends CharacterBody2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var health_component:HealthComponent = $health_component
@onready var velocity_component:Velocity_controller = $velocity_component

func _physics_process(_delta: float) -> void:
	velocity_component.accelerate_to_player()
	velocity_component.move(self)
	if velocity.x<0:
		animated_sprite_2d.flip_h=true
	if velocity.x>0:
		animated_sprite_2d.flip_h=false
