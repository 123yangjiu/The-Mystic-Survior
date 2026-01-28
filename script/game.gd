extends Node2D
class_name Game
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

func _input(event: InputEvent) -> void:
    if event.is_action_released("暂停"):
        get_viewport().set_input_as_handled()
        stop_game()

func stop_game()->void:
    GameEvent.paused+=1
    get_tree().paused=true
    GameEvent.game_stop.emit()
    var screen=stop_screen.instantiate()
    add_child(screen)
