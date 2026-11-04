class_name Enemy
extends CharacterBody2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var health_component:HealthComponent = $health_component

var all_component:Array[EnemyComponent]
@export var _id:EnemyUnlockEntry.ALL_ID

#“老怪”标记：出生超过 new_time 秒才算，用来决定能不能被回收（见 enemy_manager.check_health）
#以前是每只敌人 new 一个 Timer 节点来翻这个标记，几百只怪就是几百个计时器；
#现在只记一个出生时间戳，用属性现算，省掉每个敌人的一个节点 + 一次信号连接。
var is_old:bool : get = _get_is_old
var new_time:=3.0
var _spawn_time:=Time.get_ticks_msec()   # 先给个合理初值，免得 ready 之前被读成“老怪”

func _ready() -> void:
	_spawn_time=Time.get_ticks_msec()
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

func _get_is_old()->bool:
	return Time.get_ticks_msec()-_spawn_time>=new_time*1000.0
