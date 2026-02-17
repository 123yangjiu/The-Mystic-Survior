extends AbilityController


func set_variable()->void:
	#检测范围，数量
	max_range=150
	number = 2
	#伤害，大小,速度
	init_damage =22

func return_position():
	var ran_R=randfn(60,10)
	var target_position=GameEvent.play_global_position+Vector2.RIGHT.rotated(randf_range(0, TAU)) * ran_R
	return target_position

func on_ability_upgrade_add(upgrade:AbilityUpgrade,_current_upgrade:Dictionary):
	if upgrade.ID=="更快愤怒":
		wait_range -=0.2
		timer.wait_time=max(base_wait_time*wait_range,base_wait_time*0.1)
		volume_range -=0.05
		var db_value = volume+20 * log(volume_range) / log(10)
		db_value = clamp(db_value, -80, 6)
		audio.volume_db = db_value
	if upgrade.ID=="更强愤怒":
		damage_range*=1.25
	if upgrade.ID=="更多愤怒":
		number+=2
	if upgrade.ID=="解锁天堂之怒":
		timer.start()
