class_name InvisibleComponent
extends EnemyComponent

@onready var durat: Timer = $Durat
@onready var inter: Timer = $Inter


@export var duration:=0.6
@export var interval:=1.5

func initial()->void:
	durat.wait_time = duration
	inter.wait_time=interval
	inter.start()


func _on_durat_timeout() -> void:
	inter.start()
	var _owner = owner as Enemy
	_owner.animated_sprite_2d.visible=true


func _on_inter_timeout() -> void:
	durat.start()
	var _owner = owner as Enemy
	_owner.animated_sprite_2d.visible=false
