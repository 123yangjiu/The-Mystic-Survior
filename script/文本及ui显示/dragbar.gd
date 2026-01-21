extends Control

@onready var texture_progress_bar: TextureProgressBar = $TextureProgressBar
@onready var button: Button = $Button

var button_down:bool

func _ready() -> void:
	pass # Replace with function body.


func _process(delta: float) -> void:
	if button_down:
		var mouse_position_x := get_global_mouse_position().x
		mouse_position_x=min(texture_progress_bar.global_position.x,mouse_position_x)
		mouse_position_x=max(texture_progress_bar.global_position.x+texture_progress_bar.size.x,mouse_position_x)
		button.global_position.x =mouse_position_x
		var value_change=(mouse_position_x-texture_progress_bar.global_position.x)*100/texture_progress_bar.size.x
		texture_progress_bar.value=value_change

func _on_button_button_down() -> void:
	button_down=true

func _on_button_button_up() -> void:
	button_down=false
