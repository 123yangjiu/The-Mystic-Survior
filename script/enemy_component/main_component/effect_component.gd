class_name EffectComponent
extends EnemyComponent

#所有动画
@onready var wolf_animation: AnimatedSprite2D = $WolfAnimation


func initial()->void:
	set_collision_disappear()

func set_collision_disappear()->void:
	GameEvent.collision_disappear.connect(on_collision_disappear)
	GameEvent.collision_disappear_end.connect(on_collision_disappear_end)
	var _owner = owner as Enemy
	if ! _owner.is_node_ready():
		await _owner.ready
	if GameEvent.is_co_disappear:
		_owner.animated_sprite_2d.modulate.a =0.6


func on_collision_disappear()->void:
	var _owner = owner as Enemy
	if GameEvent.play_global_position <_owner.global_position:
		wolf_animation.flip_h =true
	var tween = create_tween()
	wolf_animation.play("wolf")
	wolf_animation.visible=true
	tween.tween_property(_owner.animated_sprite_2d,"modulate:a",0.6,1.0)
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.parallel().tween_property(wolf_animation,"position:y",-25,1.0)
	await tween.finished
	wolf_animation.visible=false
	
	

func on_collision_disappear_end()->void:
	var _owner = owner as Enemy
	var tween = create_tween()
	tween.tween_property(_owner.animated_sprite_2d,"modulate:a",1.0,0.5)
