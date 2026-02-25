class_name Enemy
extends CharacterBody2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var health_component:HealthComponent = $health_component
#@onready var velocity_component:VelocityController = $velocity_component
#@onready var drop_component: DropComment = $drop_component

var all_component:Array[EnemyComponent]

func _ready() -> void:
	var is_co :=false
	for component in all_component:
		if component is CollisionComponent:
			is_co = true
	if ! is_co:
		self.set_collision_layer_value(3,false)
		self.set_collision_mask_value(3,false)
