extends Control

## 已停用：游戏现在一启动就进 scene/大场景/main_map.scn，
## “开始游戏 / 设置 / 图鉴 / 难度”这些大厅功能改为在地图上和物品互动来完成。
## 这个场景留着只是方便对照原来的做法，不再是游戏入口，也不需要维护。

@onready var main_theme: AudioStreamPlayer = $MainTheme
@export var setting_screen:PackedScene

func _ready() -> void:
	GameEvent.is_start=false
	GameEvent.start(true)
	await get_tree().create_timer(0.2).timeout
	main_theme.play()

func _on_开始_button_up() -> void:
	get_tree().change_scene_to_file("res://scene/大场景/game.scn")
	GameEvent.start(true)
	GameEvent.paused=0
	GameEvent.difficulty=1
	GameEvent.the_first=0
	GameEvent.is_start=true
	GameEvent.is_co_disappear=false
	GameEvent.increase_percent = 1.0
	GameEvent.difficulty_timer.start()
	queue_free()

func _on_离开_button_up() -> void:
	get_tree().quit()

func _on_setting_button_up() -> void:
	var _setting_screen = setting_screen.instantiate()
	add_child(_setting_screen)