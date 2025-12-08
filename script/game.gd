extends Node2D
class_name holy_right_ruling
@onready var hitbox_component: HitboxComponent = $"hitbox component"
@onready var animation_player: AnimationPlayer = $AnimationPlayer
func _ready() -> void:
    change_direction()
    #Engine.time_scale=2

func change_direction():
    var player=get_tree().get_first_node_in_group("player") as  Player
    if player.direction.x<0:
        self.scale.x=-1
    pass
    
