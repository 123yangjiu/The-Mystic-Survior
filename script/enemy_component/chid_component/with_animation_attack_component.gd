class_name AnimationAttackComponent
extends AttackComponent


func _process(_delta: float) -> void:
	var _owner = owner as Enemy
	if _owner.velocity.x<=0:
		self.scale.x =-1
	else:
		self.scale.x =1


func set_disable()->void:
	if collision_shape_2d.disabled==true:
		collision_shape_2d.disabled = false
	else :
		collision_shape_2d.disabled = true
