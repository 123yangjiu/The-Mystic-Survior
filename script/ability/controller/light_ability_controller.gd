extends AbilityController

var flip

func set_variable()->void:
	#检测范围，数量
	max_range=200
	number = 1
	#伤害，大小,速度
	init_damage =29.0

func return_position():
	return GameEvent.play_global_position +Vector2(0,-20)

func on_ability_upgrade_add(upgrade:AbilityUpgrade,_current_upgrade:Dictionary):
	if upgrade.ID=="光的速度":
		wait_range -=0.2
		timer.wait_time=max(base_wait_time*wait_range,base_wait_time*0.1)
	if upgrade.ID=="光的力量":
		damage_range*=1.3
		scale_range*=1.20
		max_range *=1.20
	if upgrade.ID=="解锁光剑":
		timer.start()

func set_base(instance,_target_position:Vector2)->void:
	if audio:
		audio.play()
	instance.scale.y= init_scale.y*scale_range
	instance.attack_component.damage = init_damage*damage_range
	instance.global_position = return_position()
