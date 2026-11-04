class_name CodexData
extends RefCounted

## 图鉴的数据来源：敌人从 resource/enemy/*.tres + 场景组件里读，
## 技能从玩家身上的能力控制器读，升级卡从 resource/upgrades/**.tres 读。界面只负责画。

const DIFFICULTY_SECONDS := 37.0   # 难度每 37 秒 +1

const ENEMY_NAMES := {
	"silime": "史莱姆",
	"purple_silime": "红史莱姆",
	"avocado": "亡灵鳄梨",
	"wolf": "蓝狼",
	"owl": "猫头鹰",
	"gorlen": "石头人",
	"box": "箱子",
	"escape_box": "逃跑箱子",
	"knight": "骑士",
	"red_wolf": "红狼",
	"witch": "巫婆",
	"mushroom": "蘑菇",
	"undead": "亡灵",
	"laser_gorlen": "激光石头人",
	"skeleton": "骷髅",
}

## 组件 → 技能名 + 说明（组件是通用的，这里负责起名字）
const SKILL_INFO := {
	"rush_component": ["冲刺", "每隔几秒向玩家高速冲一次"],
	"summon_component": ["召唤", "周期召唤小怪"],
	"invisible_component": ["隐身", "周期性隐身，只露出影子"],
	"blink_component": ["闪现", "周期性瞬移一段距离"],
	"copy_component": ["分身", "受击时分裂出分身"],
	"disappear_component": ["定时消失", "一段时间后自动消失"],
	"check_ability_component": ["远程技能", "玩家进入范围后释放技能"],
	"with_animation_attack_component": ["连击", "攻击动作和动画帧同步"],
	"check_attack_component": ["条件攻击", "满足条件才发起攻击"],
}

## 个别敌人对通用技能名的覆盖
const SKILL_OVERRIDE := {
	"laser_gorlen": {"check_ability_component": ["激光攻击", "蓄力后发射一道激光"]},
}

## 想给某个能力/角色能力配演示视频：在这里填 res:// 路径（.ogv），图鉴里会自动替换掉动画预览。
## 键 = 能力节点名（sword_ability_controller…）或升级卡文件名（iron_stone / speed_up…）
const ABILITY_VIDEO := {
}

## 有些能力拿不到 init_damage / Timer（比如枪是一整套弹夹系统），单独写死显示文字
const ABILITY_STATS_OVERRIDE := {
	"AllGunAbilityController": ["由枪械决定", "0.05 秒/发"],
}

## 满级（每张升级卡选 4 次）：
## damage_mult = 每次伤害倍率（^4），interval_scale = 4 次后的间隔倍率（wait_range 1 - 0.2×4）
const MAX_STATS := {
	"sword_ability_controller": {"damage_mult": 1.35, "interval_scale": 0.2, "notes": ["剑 +4 把（共 5 把）"]},
	"Fireball_controller": {"damage_mult": 1.2, "interval_scale": 0.2, "notes": ["穿透 +12", "火球 +4 发（共 5 发）"]},
	"heaven_fury_controller": {"damage_mult": 1.25, "interval_scale": 0.2, "notes": ["光柱 +8 道（共 9 道）"]},
	"light_ability_controller": {"damage_mult": 1.3, "interval_scale": 0.2, "notes": ["光剑尺寸 +107%"]},
	"ring_ability_controller": {"damage_mult": 1.35, "interval_scale": 0.2, "notes": ["法环尺寸 +75%"]},
	"AllGunAbilityController": {"text": "以默认步枪计：伤害 ×2.86、弹夹 ×2.07、换弹 -40%"},
}

## 玩家能力：控制器场景 → 显示名 / 升级卡分类 / 一句介绍
## 这里直接从控制器场景读数值（实例化后调 set_variable()），所以图鉴不依赖"玩家在不在场上"
const ABILITY_TABLE := [
	{"key": "sword_ability_controller", "path": "res://scene/ability/sword_ability/sword_ability_controller.tscn", "name": "剑", "sort": "剑", "desc": "在头顶生成一把剑，砍向最近的敌人"},
	{"key": "Fireball_controller", "path": "res://scene/ability/fireball_ability/fireball_controller.tscn", "name": "火球", "sort": "火球", "desc": "朝最近的敌人发射火球，可以穿透"},
	{"key": "light_ability_controller", "path": "res://scene/ability/holy_light_ability/light_ability_controller.tscn", "name": "圣光", "sort": "光剑", "desc": "头顶凝聚光剑，砍下造成巨量伤害"},
	{"key": "heaven_fury_controller", "path": "res://scene/ability/heaven_fruy/heaven_fruy_controller.tscn", "name": "天堂之怒", "sort": "天堂", "desc": "在周围随机落下光柱"},
	{"key": "ring_ability_controller", "path": "res://scene/ability/ring_ability/ring_ability_controller.tscn", "name": "法环", "sort": "环", "desc": "周围涌现死灵法环，攻击环内所有敌人"},
	{"key": "AllGunAbilityController", "path": "res://scene/ability/AK47_ability/all_gun_ability_controller.tscn", "name": "枪", "sort": "枪", "desc": "自动攻击最近的敌人，按弹夹换弹"},
]

#---- 敌人 ----
static func all_enemies() -> Array[Dictionary]:
	var list: Array[Dictionary] = []
	var dir := DirAccess.open("res://resource/enemy")
	if dir == null:
		return list
	for file in dir.get_files():
		if ! file.ends_with(".tres"):
			continue
		var key := file.get_basename()
		var entry: EnemyUnlockEntry = load("res://resource/enemy/" + file)
		if entry == null:
			continue
		list.append(_enemy_entry(entry, key))
	list.sort_custom(_enemy_sort)
	return list

## 按 unlock_difficulty 的绝对值从小到大排（-20 的亡灵排在 11 的石头人后面）
static func _enemy_sort(a: Dictionary, b: Dictionary) -> bool:
	var a_abs := absi(int(a.unlock))
	var b_abs := absi(int(b.unlock))
	if a_abs == b_abs:
		return a.name < b.name
	return a_abs < b_abs

static func _enemy_entry(entry: EnemyUnlockEntry, key: String) -> Dictionary:
	var stats := _read_enemy_scene(entry.scene, key)
	return {
		"key": key,
		"name": ENEMY_NAMES.get(key, key),
		"unlock": entry.unlock_difficulty,
		"disappear": entry.disapear_difficulty,
		"weight": entry.weight,
		"hp": stats.hp,
		"speed": stats.speed,
		"damage": stats.damage,
		"skills": stats.skills,
		"scene": entry.scene,
	}

## 实例化敌人场景（不进树，所以组件的 _ready 不会跑），读组件上的导出值
static func _read_enemy_scene(scene: PackedScene, key: String) -> Dictionary:
	var result := {"hp": 0.0, "speed": 0.0, "damage": 0.0, "skills": []}
	if scene == null:
		return result
	var root := scene.instantiate()
	var seen := {}
	var skills: Array[Dictionary] = []
	for child in root.get_children():
		if child is HealthComponent:
			result.hp = child.max_health
		elif child is VelocityController:
			result.speed = child.speed
		elif child is AttackComponent:
			result.damage = child.damage
		var script_path := ""
		if child.get_script():
			script_path = child.get_script().resource_path
		if script_path != "":
			var key_skill := script_path.get_file().get_basename()
			if SKILL_INFO.has(key_skill) and ! seen.has(key_skill):
				seen[key_skill] = true
				var info: Array = SKILL_INFO[key_skill]
				var override: Dictionary = SKILL_OVERRIDE.get(key, {})
				if override.has(key_skill):
					info = override[key_skill]
				skills.append({"name": info[0], "desc": info[1]})
	result.skills = skills
	root.free()
	return result

static func difficulty_to_time(difficulty: int) -> String:
	var seconds := int(maxi(difficulty, 0) * DIFFICULTY_SECONDS)
	return "%d:%02d" % [seconds / 60, seconds % 60]

#---- 技能 ----
## 六个主动能力：实例化控制器场景、调一次 set_variable() 读基础数值（不进树，不跑 _ready）
static func all_abilities() -> Array[Dictionary]:
	var list: Array[Dictionary] = []
	for item: Dictionary in ABILITY_TABLE:
		var entry := {
			"key": String(item.key),
			"name": String(item.name),
			"sort": String(item.sort),
			"desc": String(item.desc),
			"active": true,
			"damage": -1.0,
			"interval": -1.0,
			"damage_text": "—",
			"interval_text": "—",
			"ability": null,
			"video": String(ABILITY_VIDEO.get(String(item.key), "")),
		}
		var override: Array = ABILITY_STATS_OVERRIDE.get(String(item.key), [])
		if override.size() == 2:
			entry.damage_text = override[0]
			entry.interval_text = override[1]
		else:
			var scene := load(String(item.path)) as PackedScene
			if scene:
				var inst := scene.instantiate()
				if inst.has_method("set_variable"):
					inst.set_variable()
				if inst.get("init_damage") != null:
					var damage := float(inst.get("init_damage")) * float(inst.get("damage_range"))
					var timer := inst.get_node_or_null("Timer") as Timer
					if timer == null:
						timer = inst.get_node_or_null("Reload") as Timer
					entry.damage = damage
					entry.interval = timer.wait_time if timer else 0.0
					entry.damage_text = "%.0f" % damage
					entry.interval_text = "%.2f 秒" % entry.interval
				entry.ability = inst.get("ability")
				inst.free()
		list.append(entry)
	#角色能力（被动卡）也列进去，它们没有攻击动画，留给作者之后补视频
	for card in upgrade_cards("角色能力"):
		list.append({
			"key": String(card.file),
			"name": card.id,
			"sort": "角色能力（被动）",
			"desc": card.desc,
			"flavor": card.name,
			"active": false,
			"damage_text": "—",
			"interval_text": "—",
			"ability": null,
			"video": String(ABILITY_VIDEO.get(String(card.file), "")),
		})
	return list

## 满级数值：伤害 = 基础 × 倍率^4；间隔 = 基础 × 缩放；拿不到数值的（枪）给一段文字
static func max_stats(entry: Dictionary) -> Dictionary:
	var data: Dictionary = MAX_STATS.get(String(entry.get("key", "")), {})
	if data.has("text"):
		return {"text": String(data.text)}
	var base_damage := float(entry.get("damage", -1.0))
	if base_damage < 0.0:
		return {"text": "—"}
	return {
		"damage": base_damage * pow(float(data.get("damage_mult", 1.0)), 4.0),
		"interval": float(entry.get("interval", 0.0)) * float(data.get("interval_scale", 1.0)),
		"notes": data.get("notes", []),
	}

## 某个分类下的升级卡
static func upgrade_cards(sort: String) -> Array[Dictionary]:
	var list: Array[Dictionary] = []
	_scan_cards("res://resource/upgrades", sort, list)
	list.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return a.name < b.name)
	return list

static func _scan_cards(dir_path: String, sort: String, out: Array[Dictionary]) -> void:
	var dir := DirAccess.open(dir_path)
	if dir == null:
		return
	for sub in dir.get_directories():
		_scan_cards(dir_path + "/" + sub, sort, out)
	for file in dir.get_files():
		if ! file.ends_with(".tres"):
			continue
		var card: AbilityUpgrade = load(dir_path + "/" + file)
		if card == null or card.Sort != sort:
			continue
		out.append({"file": file.get_basename(), "id": card.ID, "name": card.name, "desc": card.Description})

#---- 动画预览 ----
## 只把场景里的"画"的部分摘出来（Sprite / AnimatedSprite / AnimationPlayer），
## 其余带逻辑的节点全部丢掉，避免在预览里跑敌人/投射物的 _ready。
## 挑一个"有内容"的动画：跳过 RESET，优先取最长的那个
static func _pick_animation(player: AnimationPlayer) -> String:
	var best := ""
	var best_length := 0.0
	for name in player.get_animation_list():
		if name == "RESET":
			continue
		var anim := player.get_animation(name)
		if anim.length > best_length:
			best_length = anim.length
			best = name
	return best

static func preview(scene: PackedScene, max_size: float) -> Node2D:
	var stage := Node2D.new()
	stage.process_mode = Node.PROCESS_MODE_ALWAYS
	stage.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	if scene == null:
		return stage
	var inst := scene.instantiate()
	var anim_player: AnimationPlayer = null
	var chosen := ""
	#先看 AnimationPlayer 的轨道引用了哪些节点，这些节点要一起留下来
	var needed := {}
	for child in inst.get_children():
		if child is AnimationPlayer:
			anim_player = child as AnimationPlayer
			#场景里可能设了 autoplay（比如剑是 autoplay="swing"），进树会自动播原动画（带方法轨道），先关掉
			anim_player.autoplay = ""
			chosen = _pick_animation(anim_player)
			if chosen != "":
				var src: Animation = anim_player.get_animation(chosen)
				for t in src.get_track_count():
					var path_str := String(src.track_get_path(t))
					var head := path_str.split(":")[0].split("/")[0]
					needed[head] = true
	#只摘"画"和动画相关的节点，带逻辑的丢给引擎回收
	for child in inst.get_children():
		if child is AnimatedSprite2D or child is Sprite2D or child is AnimationPlayer or needed.has(String(child.name)):
			child.reparent(stage)
	inst.free()
	var size := Vector2(16, 16)
	for node in stage.get_children():
		if node is AnimatedSprite2D:
			var sprite := node as AnimatedSprite2D
			if sprite.sprite_frames:
				var names: PackedStringArray = sprite.sprite_frames.get_animation_names()
				if names.size() > 0:
					var anim := names[0]
					sprite.play(anim)
					var tex := sprite.sprite_frames.get_frame_texture(anim, 0)
					if tex:
						size = tex.get_size()
			break
		if node is Sprite2D:
			var spr := node as Sprite2D
			if spr.texture:
				size = spr.texture.get_size()
			break
	#AnimationPlayer：复制一份动画、删掉方法轨道（queue_free / flip / the_first_damage），再循环播
	if anim_player:
		if chosen != "":
			var anim: Animation = anim_player.get_animation(chosen).duplicate(true)
			for t in range(anim.get_track_count() - 1, -1, -1):
				if anim.track_get_type(t) == Animation.TYPE_METHOD:
					anim.remove_track(t)
			anim.loop_mode = Animation.LOOP_LINEAR
			var lib: AnimationLibrary = anim_player.get_animation_library("")
			if lib == null:
				lib = AnimationLibrary.new()
				anim_player.add_animation_library("", lib)
			lib.add_animation("__preview", anim)
			anim_player.stop()
			anim_player.play("__preview")
	#像素图只能用整数倍放大，否则边缘会糊
	var factor := maxf(1.0, floorf(max_size / maxf(size.x, size.y)))
	stage.scale = Vector2(factor, factor)
	return stage
