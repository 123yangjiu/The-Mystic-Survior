extends Area2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
var base_radius: float = 20.0

func _ready() -> void:
	GameEvent.ability_upgrade_add.connect(on_ability_upgrade_add)
func on_ability_upgrade_add(upgrade:AbilityUpgrade,current_upgrade:Dictionary):
	if upgrade.ID=="吸铁石":
		base_radius=base_radius+current_upgrade["吸铁石"]["quantity"]*18
		var c = CircleShape2D.new()
		c.radius = base_radius
		collision_shape_2d.shape = c
