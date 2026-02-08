extends Node2D
class_name Game
#@onready var hitbox_component: HitboxComponent = $"hitbox component"
#@onready var animation_player: AnimationPlayer = $AnimationPlayer
@export var stop_screen:PackedScene

func _ready() -> void:
	change_direction()
	#测试内容
	#Engine.time_scale=2
	#await get_tree().create_timer(4).timeout
	#GameEvent.difficulty=16
	#GameEvent.emit_more_difficulty()

func change_direction():
	var player=get_tree().get_first_node_in_group("player") as  Player
	if player.direction.x<0:
		self.scale.x=-1

func _input(event: InputEvent) -> void:
	if event.is_action_released("暂停"):
		get_viewport().set_input_as_handled()
		GameEvent.stop_game(true)
		var screen=stop_screen.instantiate()
		add_child(screen)
