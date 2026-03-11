extends CanvasLayer

func _ready() -> void:
	GameEvent.stop_game()
	#成就系统
	match GameEvent.mode_index:
		1:
			AchievementManager.unlock_achievement(AchievementManager.AchievementID.normal_finished)
		2:
			AchievementManager.unlock_achievement(AchievementManager.AchievementID.hard_finished)
		3:
			for i in GameEvent.hard_mode:
				if ! i:
					return
			AchievementManager.unlock_achievement(AchievementManager.AchievementID.all_challenge_finished)
	if GameEvent.special_moster_dead_number==0 and GameEvent.mode_index >=2:
		AchievementManager.unlock_achievement(AchievementManager.AchievementID.love_and_peace)
