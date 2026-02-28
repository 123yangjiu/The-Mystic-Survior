class_name EnemyComponent
extends Node2D



func _ready()->void:
	if ! owner is Enemy:
		if !owner:
			owner=get_parent()
		else :
			owner = owner.get_parent()
	if ! owner.is_node_ready():
		await owner.ready
	if owner is Enemy:
		owner.all_component.append(self)
	initial()

func initial()->void:
	pass
