extends Node

## 敌人数据扫描工具（不是游戏的一部分）
##
## 用途：把「游戏内实际生效的敌人数据」导出成 JSON + 立绘 PNG，
##       供 docs/enemies.html 这个图鉴网页使用。
##
## 怎么跑：
##   1. 用 Godot 打开工程；
##   2. 在文件系统里双击打开 res://tools/dump_enemies.tscn，按 F6 单独运行这个场景；
##      （也可以命令行：godot --path . res://tools/dump_enemies.tscn）
##   3. 跑完会自动退出，数据写到 docs/enemies-data.json、立绘画到 docs/images/enemies/。
##
## 为什么要"实例化场景"而不是读 .tscn 文本：
##   血量、速度、伤害这些值有的写在组件导出的默认值里、有的写在场景实例覆盖里，
##   只有把场景真的实例化出来读，才是**游戏里实际生效的数**。

const OUT_JSON := "res://docs/enemies-data.json"
const OUT_DIR := "res://docs/images/enemies/"

func _ready() -> void:
	await get_tree().process_frame
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT_DIR))
	var list: Array = []
	await _collect_from_resources(list)
	await _collect_scenes_without_data(list)
	#按 ID 排序，没有 ID 的（skeleton 之类）排最后
	list.sort_custom(func(a:Dictionary, b:Dictionary) -> bool:
		var ai: int = a.id if a.id >= 0 else 999
		var bi: int = b.id if b.id >= 0 else 999
		return ai < bi)
	var file := FileAccess.open(OUT_JSON, FileAccess.WRITE)
	file.store_string(JSON.stringify(list, "  "))
	file.close()
	print("DUMP|count=", list.size(), " -> ", OUT_JSON)
	get_tree().quit()

## 遍历 resource/enemy 下的数据资源，逐个把对应场景实例化出来读数值
func _collect_from_resources(list: Array) -> void:
	for f in DirAccess.get_files_at("res://resource/enemy"):
		if ! f.ends_with(".tres"):
			continue
		var res: EnemyUnlockEntry = load("res://resource/enemy/" + f)
		if res == null or res.scene == null:
			continue
		var entry := {
			"file": f.get_basename(),
			"scene": res.scene.resource_path,
			"id": int(res.ID),
			"id_name": EnemyUnlockEntry.ALL_ID.keys()[int(res.ID)],
			"weight": res.weight,
			"unlock_difficulty": res.unlock_difficulty,
			"disapear_difficulty": res.disapear_difficulty,
			"data_max_health": res.max_health,
		}
		await _instantiate_and_read(entry, res.scene)
		list.append(entry)

## 有场景但没数据资源的敌人（比如 skeleton），单独扫出来标注"未启用"
func _collect_scenes_without_data(list: Array) -> void:
	var known: Array = []
	for e in list:
		known.append(str(e.scene).get_file())
	for s in DirAccess.get_files_at("res://scene/enemy"):
		var file_name := str(s)
		if ! file_name.ends_with(".tscn") or file_name.begins_with("enemy_template"):
			continue
		if known.has(file_name):
			continue
		var path := "res://scene/enemy/" + file_name
		var entry := {
			"file": file_name.get_basename(),
			"scene": path,
			"id": -1,
			"id_name": "",
			"weight": 0.0,
			"unlock_difficulty": 0,
			"disapear_difficulty": 0,
			"data_max_health": 0.0,
			"no_data": true,
		}
		await _instantiate_and_read(entry, load(path) as PackedScene)
		list.append(entry)

func _instantiate_and_read(entry: Dictionary, packed: PackedScene) -> void:
	var inst: Node = packed.instantiate()
	add_child(inst)
	await get_tree().process_frame
	entry["root_name"] = inst.name
	var hc = inst.get("health_component")
	if hc:
		entry["max_health"] = hc.max_health
	var comps: Array = []
	for c in inst.get_children():
		var scr = c.get_script()
		if scr:
			comps.append(scr.resource_path.get_file().get_basename())
	entry["components"] = comps
	for c in inst.get_children():
		if ! entry.has("speed") and c is VelocityController:
			entry["speed"] = c.speed
			entry["acceleration"] = c.acceleration
			entry["turn_rate"] = c.turn_rate
		if ! entry.has("damage") and c is AttackComponent:
			entry["damage"] = c.damage
			entry["attack_type"] = int(c.type)
	_save_portrait(entry, inst)
	inst.queue_free()
	await get_tree().process_frame

## 立绘：取第一个动画的第 0 帧，裁掉透明边，存成 png
func _save_portrait(entry: Dictionary, inst: Node) -> void:
	var sprite: AnimatedSprite2D = inst.get_node_or_null("AnimatedSprite2D")
	if sprite == null or sprite.sprite_frames == null:
		return
	var anims := sprite.sprite_frames.get_animation_names()
	entry["animations"] = anims
	for a in anims:
		if sprite.sprite_frames.get_frame_count(a) <= 0:
			continue
		var tex := sprite.sprite_frames.get_frame_texture(a, 0)
		if tex == null:
			continue
		entry["sprite_source"] = tex.atlas.resource_path if tex is AtlasTexture else tex.resource_path
		var img := tex.get_image()
		if img:
			var used := img.get_used_rect()
			if used.size.x > 0 and used.size.y > 0:
				img = img.get_region(used)
			var path: String = OUT_DIR + str(entry.file) + ".png"
			img.save_png(path)
			entry["portrait"] = path.replace("res://docs/", "")
			entry["portrait_size"] = [img.get_width(), img.get_height()]
		break
