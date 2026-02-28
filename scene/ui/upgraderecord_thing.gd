extends HBoxContainer
@onready var label: Label = $Label
@onready var label_2: Label = $Label2
func on_ability_upgrade_add(upgrade:AbilityUpgrade,current_upgrade:Dictionary):
    if upgrade.ID=="解锁火球":
        label.text="火球"
        
