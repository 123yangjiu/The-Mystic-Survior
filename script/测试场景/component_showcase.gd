class_name ComponentShowcase
extends Node2D

## 组件展示场景：只摆外观，不接任何实际逻辑。
## 以后加新组件就往场景里拖，下面这段会自动把它们"关掉"：
## 传送门不响应进入、不切场景。

func _ready() -> void:
	for child in get_children():
		if child is Portal:
			_setup_portal(child as Portal)

func _setup_portal(portal: Portal) -> void:
	portal.start_run = false
	portal.target_scene = null
	portal.target_path = ""
	for area_name in ["Area2D", "NearArea2D"]:
		var area := portal.get_node_or_null(area_name) as Area2D
		if area:
			area.monitoring = false
			area.monitorable = false
