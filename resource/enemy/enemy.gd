extends Resource
class_name EnemyUnlockEntry

enum ALL_ID{
	slime,
	red_slime,
	avocado,
	wolf,
	owl,
	gorlen,
	box,
	escape_box,
	knight,
	red_wolf,
	witch,
	mushroom,
	undead
}

@export var scene: PackedScene
@export var unlock_difficulty: int = 1
@export var weight:float
@export var ID:ALL_ID
@export var disapear_difficulty:int=100
@export var max_health:float
