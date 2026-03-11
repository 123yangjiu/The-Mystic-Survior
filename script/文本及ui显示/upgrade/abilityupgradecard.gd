class_name AbilityCard
extends PanelContainer
@onready var name_label: Label = $VBoxContainer/NameLabel
@onready var description_label: Label = $VBoxContainer/DescriptionLabel
@onready var number_label: Label = $MarginContainer/NumberLabel

signal selected
signal in_ready
signal no_ready

func _ready() -> void:
	gui_input.connect(on_gui_input)
func set_ability_upgrade(upgrade:AbilityUpgrade):
	name_label.text=upgrade.name
	description_label.text=upgrade.Description
	if upgrade.number>0:
		number_label.visible=true
		number_label.text = "已获得次数："+str(upgrade.number)

func on_gui_input(event:InputEvent):#传入输入事件
	if event.is_action_pressed("click"):
		selected.emit()

func _on_texture_rect_mouse_entered() -> void:
	modulate = Color(1.0, 1.0, 1.0, 1.0)
	in_ready.emit()

func _on_texture_rect_mouse_exited() -> void:
	modulate = Color(1.0, 1.0, 1.0, 0.784)
	no_ready.emit()
