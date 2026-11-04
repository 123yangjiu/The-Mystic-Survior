extends Portal

## 玩家专用的传送门：角色走进来 → 把一局游戏的状态准备好 → 切到目标场景开始游玩。
## 外观动画全在 Portal（portal.gd）里，这里只负责“谁来、什么时候走、走去哪”。

@export var target_scene:PackedScene
## 目标场景的路径：填了就用它（适合"两个场景互相传送"这种不能用 PackedScene 硬引用的场合）
@export var target_path:=""
@export var fade_lead:=0.5       # 吸人动画播到第几秒开始淡出（几乎贴着动画结束，省掉干等）
@export var start_run:=true      # 进门前要不要 GameEvent.begin_run()（训练场这类不算一局的场景设为 false）

@onready var area_2d:Area2D = get_node_or_null("Area2D") as Area2D
@onready var near_area:Area2D = get_node_or_null("NearArea2D") as Area2D

func _ready()->void:
	super()
	if area_2d:
		area_2d.body_entered.connect(_on_area_2d_body_entered)
	if near_area:
		near_area.body_entered.connect(_on_near_area_body_entered)
		near_area.body_exited.connect(_on_near_area_body_exited)

#---- 靠近：门醒来 ----
func _on_near_area_body_entered(who:Node2D)->void:
	if who is Player:
		set_wake(true)

func _on_near_area_body_exited(who:Node2D)->void:
	if who is Player:
		set_wake(false)

#---- 进入：开始一局 ----
func _on_area_2d_body_entered(who:Node2D)->void:
	if is_leaving:
		return
	if ! who is Player:
		return
	enter_game(who)

## 玩家走进传送门：
## 1. 播门的进入动画（收缩 + 冲击波 + 粒子爆发），同时把角色的立绘吸进门里
## 2. 把一局游戏需要的全局状态准备好（原来是主界面“开始游戏”按钮里做的事）
## 3. 浅蓝色淡出 → 切到 game.scn → 淡入
func enter_game(who:Player)->void:
	var scene:PackedScene = target_scene
	if target_path != "":
		scene = load(target_path) as PackedScene
	if ! scene:
		push_warning("传送门没有设置 target_scene / target_path，无法进入")
		return
	play_enter()
	#立绘开始被吸。这里故意不 await：让"吸人"和"淡出"并行播放，不用等动画播完才开始淡出
	who.be_sucked(global_position)
	await get_tree().create_timer(fade_lead).timeout
	if start_run:
		GameEvent.begin_run()
	#淡出只用 0.2s：动画基本播完再快速变白，玩家不会觉得"动画没播完就被切走了"
	ScreenFade.change_scene(scene,Color(0.78,0.9,1.0),0.2,0.25)
