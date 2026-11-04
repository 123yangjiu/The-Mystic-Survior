extends Node

## 升级卡（玩家能力）数据扫描工具（不是游戏的一部分）
##
## 用途：把 resource/upgrades/ 下所有 AbilityUpgrade 资源导出成 JSON，
##       供 docs/enemies.html 里的「玩家能力」一栏使用。
##
## 怎么跑：用 Godot 打开工程 → 双击 res://tools/dump_abilities.tscn → 按 F6。

const OUT_JSON := "res://docs/abilities-data.json"

func _ready() -> void:
	await get_tree().process_frame
	var list: Array = []
	_scan("res://resource/upgrades", list)
	list.sort_custom(func(a:Dictionary, b:Dictionary) -> bool:
		if a.sort == b.sort:
			return a.name < b.name
		return a.sort < b.sort)
	var file := FileAccess.open(OUT_JSON, FileAccess.WRITE)
	file.store_string(JSON.stringify(list, "  "))
	file.close()
	print("DUMP|abilities=", list.size(), " -> ", OUT_JSON)
	get_tree().quit()

func _scan(dir: String, list: Array) -> void:
	for sub in DirAccess.get_directories_at(dir):
		_scan(dir + "/" + sub, list)
	for f in DirAccess.get_files_at(dir):
		if ! f.ends_with(".tres"):
			continue
		var res: AbilityUpgrade = load(dir + "/" + f)
		if res == null:
			continue
		list.append({
			"file": f.get_basename(),
			"path": dir + "/" + f,
			"id": res.ID,
			"name": res.name,
			"sort": res.Sort,
			"desc": res.Description,
			"is_init": res.is_init,
			"is_unlock": res.is_unlock,
			"self_lock": res.self_lock,
			"lock_code": res.lock_code,
		})
