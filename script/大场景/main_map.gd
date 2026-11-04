extends Node2D

## 主地图（代替原来的主界面）。
## 玩家一进游戏就站在这里走动，想要什么功能就去和地图上的东西互动：
##   走进传送门 = 开始一局普通模式（目前唯一接通的功能，见 player_portal.gd）
##   以后其它入口（难度调整、能力选择、图鉴、感谢名单、退出游戏…由 占位符 里的 Label 标出）
##   都用 场景互动件/确认物体.tscn 那套“靠近 + 按 confirm”的交互来做。
##
## 这个脚本只负责大厅本身该做的事：回到大厅时把上一局的状态清干净、放大厅音乐。

## 大厅背景音乐（就是原来主界面放的那首）
@export var main_theme:AudioStream = preload("res://sucai/back_music/Brand New_0.wav")

var _music:AudioStreamPlayer

func _enter_tree() -> void:
	#从一局游戏（死亡 / 胜利 / 暂停菜单退出）回到大厅时，上一局的状态还留着：
	#暂停着的 tree、涨上去的难度、正在跑的难度计时器……这里一次清干净。
	#放在 _enter_tree 而不是 _ready：_enter_tree 是“父 → 子”、_ready 是“子 → 父”，
	#这样玩家（子节点）_ready 里读 GameEvent.is_start 时拿到的已经是 false，血条不会先闪一下。
	GameEvent.end_run()

func _ready() -> void:
	_play_main_theme()

func _play_main_theme()->void:
	if ! main_theme:
		return
	_music=AudioStreamPlayer.new()
	_music.name="MainTheme"
	_music.stream=main_theme
	_music.bus=&"Music"
	add_child(_music)
	_music.play()