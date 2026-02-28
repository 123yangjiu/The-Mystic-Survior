extends Button
@export var screen:PackedScene
@onready var label: Label = $Label

var label_text:Dictionary[int,String]={
	0:"简单",
	1:"普通",
	2:"困难",
	3:"挑战"
}
var label_color:Dictionary[int,Color]={
	0:Color(0.391, 0.65, 0.351, 1.0),
	1:Color(0.9, 0.9, 0.9, 1.0),
	2:Color(0.05, 0.05, 0.05, 1.0),
	3:Color(0.6, 0.12, 0.12, 1.0)
}

func _ready() -> void:
	if GameEvent.mode_index!=-1:
		label.text=label_text[GameEvent.mode_index]
		label.modulate=label_color[GameEvent.mode_index]
	self.pressed.connect(_on_pressed)
	GameEvent.mode_change.connect(on_mode_change)

func _on_pressed() -> void:
	var screen_scene = screen.instantiate()
	add_child(screen_scene)

func on_mode_change()->void:
	label.text=label_text[GameEvent.mode_index]
	label.modulate=label_color[GameEvent.mode_index]
