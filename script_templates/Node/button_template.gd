extends Button
@export var screen:PackedScene

func _ready() -> void:
	self.pressed.connect(_on_pressed)

func _on_pressed() -> void:
	var screen_scene = screen.instantiate()
	add_child(screen_scene)
