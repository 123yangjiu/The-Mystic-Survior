extends VBoxContainer
@export var upgradething:PackedScene
func on_ability_upgrade_add(upgrade:AbilityUpgrade,current_upgrade:Dictionary):
    var upgradething_instance=upgradething.instantiate() as Node
    self.add_child(upgradething_instance)
