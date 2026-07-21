class_name Enemy
extends CharacterBody2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var health_component:HealthComponent = $health_component

var all_component:Array[EnemyComponent]
@export var _id:EnemyUnlockEntry.ALL_ID

var is_old :=false
var new_time:=3.0

func _ready() -> void:
	var is_co :=false
	var timer = Timer.new()
	# 2. 设置属性
	timer.wait_time = new_time         # 间隔时间（秒）
	timer.one_shot = true         # false = 循环触发，true = 只触发一次
	timer.autostart=true
	
	add_child(timer)
	timer.timeout.connect(on_timer_timeout)
	
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

func on_timer_timeout()->void:
	is_old=true
