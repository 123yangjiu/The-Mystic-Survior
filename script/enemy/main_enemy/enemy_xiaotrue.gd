class_name Enemy
extends CharacterBody2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var health_component:HealthComponent = $health_component

var all_component:Array[EnemyComponent]
@export var _id:EnemyUnlockEntry.ALL_ID

func _ready() -> void:
	var is_co :=false
	for component in all_component:
		if component is CollisionComponent:
			is_co = true
	if ! is_co:
		self.set_collision_layer_value(3,false)
		self.set_collision_mask_value(3,false)

func _exit_tree() -> void:
	match _id:
		EnemyUnlockEntry.ALL_ID.knight,EnemyUnlockEntry.ALL_ID.witch,EnemyUnlockEntry.ALL_ID.undead:
			GameEvent.special_moster_dead_number+=1
