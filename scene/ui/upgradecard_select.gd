extends PanelContainer

@onready var name_label: Label = $VBoxContainer/NameLabel
@onready var description_label: Label = $VBoxContainer/DescriptionLabel

var self_upgrade:AbilityUpgrade
var free_object:Node

func set_ability_upgrade(upgrade:AbilityUpgrade):
	name_label.text=upgrade.name
	description_label.text=upgrade.Description
	self_upgrade=upgrade

func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("click"):
		GameEvent.easy_mode[GameEvent.EASY_MODE.is_initial] =self_upgrade
		free_object.queue_free()

func _on_texture_rect_mouse_entered() -> void:
	modulate = Color(1.0, 1.0, 1.0, 1.0)

func _on_texture_rect_mouse_exited() -> void:
	modulate = Color(1.0, 1.0, 1.0, 0.784)
