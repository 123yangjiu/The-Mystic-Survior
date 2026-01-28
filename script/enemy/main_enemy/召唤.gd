extends Area2D
@onready var velocity_component: Velocity_controller = $"../velocity_component"
@export var enemy:PackedScene

var can_spawn := false
var SPAWN_R=65
func _ready() -> void:
	body_entered.connect(on_body_enter)
	body_exited.connect(on_body_exited)
	$"../spawn_interval".timeout.connect(spawn_again)

func on_body_enter(_area: Node2D) -> void:
	if not _area.is_in_group("player"): return
	can_spawn = true
	do_spawn()
	$"../spawn_interval".start()   # 启动 2 s 循环

func on_body_exited(_area: Node2D) -> void:
	if not _area.is_in_group("player"): return
	can_spawn = false

func do_spawn():
	for i in 2:
		call_deferred("create_monster")


func create_monster()->void:
	var player=get_tree().get_first_node_in_group("player")
	var enemy_instane=enemy.instantiate() as Node2D
	var random_direction=Vector2.RIGHT.rotated(randf_range(0,TAU))
	var spawn_position=player.global_position+random_direction*SPAWN_R
	var entities_Layer=get_tree().get_first_node_in_group("实体图层")
	entities_Layer.add_child(enemy_instane)
	enemy_instane.global_position=spawn_position
	pass


func spawn_again():
	if can_spawn:
		do_spawn()
		$"../spawn_interval".start()
