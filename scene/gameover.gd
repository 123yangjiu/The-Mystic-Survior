extends Node2D
@export var die_scene:PackedScene
func _process(delta: float) -> void:
    var player=get_tree().get_first_node_in_group("player") as Node
    #Engine.time_scale=2
    if player==null:
        var die_scene_instance=die_scene.instantiate()
        add_child(die_scene_instance)
    
