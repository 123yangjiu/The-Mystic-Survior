extends Node

@onready var experiencemanager: Node = $"../experiencemanager"


func _upgrade()->void:
    experiencemanager.increase_experience(experiencemanager.target_experience)
