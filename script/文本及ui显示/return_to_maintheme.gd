extends Button

@export var screen:PackedScene

func _ready() -> void:
	self.pressed.connect(_on_pressed)

func _on_pressed() -> void:
	get_parent().queue_free()
	if GameEvent.is_start:
		var screen_scene = screen.instantiate()
		get_tree().change_scene_to_node(screen_scene)
