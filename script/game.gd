extends Node2D
class_name holy_right_ruling
#@onready var hitbox_component: HitboxComponent = $"hitbox component"
#@onready var animation_player: AnimationPlayer = $AnimationPlayer
@export var stop_screen:PackedScene
func _ready() -> void:
	change_direction()
	#测试内容
	#Engine.time_scale=2

func change_direction():
	var player=get_tree().get_first_node_in_group("player") as  Player
	if player.direction.x<0:
		self.scale.x=-1
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("暂停"):
		stop_game()


func stop_game()->void:
	var screen=stop_screen.instantiate()
	add_child(screen)
