class_name AnimationAttackComponent
extends AttackComponent



func _process(_delta: float) -> void:
	var _owner = owner as Enemy
	if _owner.velocity.x<=0:
		self.scale.x =-1
	else:
		self.scale.x =1
