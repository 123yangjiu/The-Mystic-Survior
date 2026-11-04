extends Button

## 结算界面 / 暂停菜单里的“返回大厅”按钮：回到 scene/大场景/main_map.scn。
##
## 这里故意用路径切场景，而不是 @export 一个 PackedScene：
##   main_map → player.tscn → 死亡界面 → 这个按钮 → main_map
## 导出场景会形成循环依赖，Godot 加载时会报 “non-existent resource”，所以改成运行时按路径加载。

@export var screen_path:="res://scene/大场景/main_map.scn"

func _ready() -> void:
	self.pressed.connect(_on_pressed)

func _on_pressed() -> void:
	get_parent().queue_free()
	if GameEvent.is_start:
		get_tree().change_scene_to_file(screen_path)
