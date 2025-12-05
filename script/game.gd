extends Node2D
@export var end_screen:PackedScene
func _ready() -> void:
	%player.health_component.died.connect(on_player_die)
func on_player_die():
	var die_screen_instance=end_screen.instantiate()
	add_child(die_screen_instance)
	pass
	
