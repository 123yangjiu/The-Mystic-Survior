extends PanelContainer
@onready var name_label: Label = $VBoxContainer/NameLabel
@onready var description_label: Label = $VBoxContainer/DescriptionLabel
signal selected
func _ready() -> void:
	gui_input.connect(on_gui_input)
func set_ability_upgrade(upgrade:AbilityUpgrade):
	name_label.text=upgrade.name
	description_label.text=upgrade.Description
	pass
func on_gui_input(event:InputEvent):#传入输入事件
	if event.is_action_pressed("click"):
		selected.emit()
	pass
	
