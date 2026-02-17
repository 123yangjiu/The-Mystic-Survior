extends AbilityController

var flip

func set_variable()->void:
	#检测范围，数量
	max_range=200
	number = 1
	#伤害，大小,速度
	init_damage =26

func attack()->void:
	var ability_instance= ability.instantiate() as LightAbility
	var foreground = get_tree().get_first_node_in_group("前景图层")
	foreground.add_child(ability_instance)#加入到场景中
	ability_instance.scale= init_scale*scale_range
	ability_instance.hitbox_component.damage =int(init_damage*damage_range+randf_range(-5,5))
	ability_instance.global_position = return_position()
	var db_value = volume+20 * log(volume_range) / log(10)
	db_value = clamp(db_value, -80, 6)

func on_ability_upgrade_add(upgrade:AbilityUpgrade,_current_upgrade:Dictionary):
	if upgrade.ID=="光的速度":
		wait_range -=0.2
		timer.wait_time=max(base_wait_time*wait_range,base_wait_time*0.1)
		volume_range -=0.05
	if upgrade.ID=="光的力量":
		damage_range*=1.2
	if upgrade.ID=="解锁光剑":
		$Timer.start()
	if upgrade.ID=="光剑变大":
		scale_range*=1.2
		max_range *=1.2
