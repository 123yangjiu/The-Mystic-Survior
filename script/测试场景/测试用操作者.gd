extends Node

@onready var experiencemanager: Node = $"../experiencemanager"
@onready var player: Player = %player
@onready var gametimemanager: Node = $"../gametimemanager"


func _upgrade()->void:
    experiencemanager.increase_experience(experiencemanager.target_experience)


func _on_enemystart_button_up() -> void:
    player.health_component.damage(player.health_component.max_health)


func _on_victory_button_up() -> void:
    gametimemanager.on_timer_timeout()
    pass # Replace with function body.
