extends AbilityController

var color_A :=255.0 #透明度
var _speed_scale :=1.0#动画速度

func set_variable()->void:
	#检测范围，数量
	max_range=200
	number = 2
	#伤害，大小,速度
	init_damage =13

func set_plus(ability_instance,_target_position)->void:
	ability_instance.modulate.a8 =color_A /scale_range
	ability_instance.animated_sprite_2d.speed_scale=_speed_scale

func on_ability_upgrade_add(upgrade:AbilityUpgrade,_current_upgrade:Dictionary):
	if upgrade.ID=="环的大速":
		set_speed(0.2)
		scale_range*=1.15
		max_range *=1.15
		color_A -=20 
		if timer.wait_time==wait_range*0.1:
			_speed_scale=1.5
	if upgrade.ID=="环的伤害":
		damage_range*=1.45
	if upgrade.ID=="解锁法环":
		timer.start()
