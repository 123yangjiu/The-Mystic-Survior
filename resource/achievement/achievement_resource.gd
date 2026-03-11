# 成就数据.gd (单例或全局访问的脚本)
extends Node
# 成就枚举 (便于代码引用)
enum AchievementID {
	normal_finished,
	hard_finished,
	all_challenge_finished,
	just_weapon_ability_hard,
	just_weapon_ability_all_challenge,
	no_rush,
	no_CD,
	love_and_peace,
	FIRST_BLOOD,
	COLLECT_100_COINS,
	BEAT_LEVEL_1,
	# ... 更多成就
}

const SAVE_PATH = "user://achievements.save"

# 成就数据结构
var achievements_data := {
	# 格式: "成就ID": {"name": "显示名称", "got": false, "got_time": 0, "progress": 0, "max_progress": 0}
	AchievementID.normal_finished: {
		"name": "已非新手",
		"got": false,
		"progress": 0,
		"max_progress": 1
	},
	AchievementID.hard_finished: {
		"name": "已是高手",
		"got": false,
		"progress": 0,
		"max_progress": 1
	},
	AchievementID.all_challenge_finished: {
		"name": "我们是冠军！",
		"got": false,
		"progress": 0,
		"max_progress": 1
	},
	AchievementID.just_weapon_ability_hard: {
		"name": "只要不停战斗就可以了Ⅰ",
		"got": false,
		"progress": 0,
		"max_progress": 1
	},
	AchievementID.just_weapon_ability_all_challenge: {
		"name": "只要不停战斗就可以了Ⅱ",
		"got": false,
		"progress": 0,
		"max_progress": 1
	},
	AchievementID.no_rush: {
		"name": "你不能冲",
		"got": false,
		"progress": 0,
		"max_progress": 6
	},
	AchievementID.no_CD: {
		"name": "无CD之人",
		"got": false,
		"progress": 0,
		"max_progress": 1
	},
	AchievementID.love_and_peace: {
		"name": "放生流",
		"got": false,
		"progress": 0,
		"max_progress": 1
	},
}

signal achievement_unlocked

func save_achievements():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		# 将成就数据转换为JSON字符串
		var json_string = JSON.stringify(achievements_data)
		file.store_string(json_string)
		return true
	else:
		push_error("无法打开成就文件进行写入: ", SAVE_PATH)
		return false

func load_achievements():
	if not FileAccess.file_exists(SAVE_PATH):
		return false  # 首次运行，没有存档
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		
		if parse_result == OK:
			var loaded_data = json.data
			# 合并数据：将加载的数据覆盖到 achievements_data 中
			_merge_data(achievements_data, loaded_data)
			return true
		else:
			push_error("解析成就文件失败: ", json.get_error_message())
			return false
	else:
		push_error("无法打开成就文件进行读取")
		return false

# 递归合并数据，确保默认数据中的字段都存在
func _merge_data(default_data, loaded_data):
	for key in loaded_data:
		if default_data.has(key):
			if typeof(default_data[key]) == TYPE_DICTIONARY and typeof(loaded_data[key]) == TYPE_DICTIONARY:
				_merge_data(default_data[key], loaded_data[key])
			else:
				default_data[key] = loaded_data[key]

# 解锁成就 (适用于非进度类)
func unlock_achievement(achievement_id:AchievementID):
	if achievements_data.has(achievement_id):
		var achievement = achievements_data[achievement_id]
		if not achievement["got"]:
			achievement["got"] = true
			achievement["progress"] = achievement["max_progress"]  # 进度满
			# 保存到文件
			save_achievements()
			# 可以在这里发送信号，通知UI更新
			achievement_unlocked.emit(achievement_id)
			return true
	return false

# 更新成就进度 (适用于进度类，如收集100个金币)
func update_achievement_progress(achievement_id, progress_value):
	if achievements_data.has(achievement_id):
		var achievement = achievements_data[achievement_id]
		if achievement["got"]:
			return false  # 已获得，不再更新
		# 更新进度，但不超过最大值
		achievement["progress"] = min(progress_value, achievement["max_progress"])
		# 检查是否达成
		if achievement["progress"] >= achievement["max_progress"]:
			achievement["got"] = true
		# 保存到文件
		save_achievements()
		# 发送进度更新信号
		# achievement_progress_updated.emit(achievement_id, achievement["progress"], achievement["max_progress"])
		return true
	return false
