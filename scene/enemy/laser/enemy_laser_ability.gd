class_name EnemyAbility
extends AgainstThing

var component:EnemyComponent
var enemy:AnimatedSprite2D

var is_flip:=true

func _physics_process(_delta: float) -> void:
	if is_flip:
		if enemy.flip_h==true:
			component.position.x = -abs(component.position.x)
		else :
			component.position.x = abs(component.position.x)

func shoot()->void:
	rotation = (GameEvent.play_global_position-global_position).angle()
	is_flip=false

func end()->void:
	enemy.play("run")
	self.queue_free()
