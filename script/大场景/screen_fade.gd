class_name ScreenFade
extends CanvasLayer

## 切场景时用的全屏淡出 / 淡入。
## 这个节点是挂在根节点（root）上而不是当前场景上的，所以切场景的时候不会被一起销毁，
## 才能做到“淡出 → 换场景 → 淡入”这一整套连贯的过渡。
##
## 用法（一行就够）：
##   ScreenFade.change_scene(preload("res://scene/大场景/game.scn"))
##   ScreenFade.change_scene(target, Color.WHITE, 0.3, 0.5)   # 自定义颜色和时长

## 同一时间只留一个过渡节点，避免叠了两层黑屏
static var current:ScreenFade

var fade_color:=Color.WHITE
var fade_out_time:=0.3
var fade_in_time:=0.45
var target_scene:PackedScene

var rect:ColorRect

## 淡出 → 切到 scene → 淡入。返回值可以 await 它的 finished 信号
static func change_scene(scene:PackedScene,color:=Color.WHITE,out_time:=0.3,in_time:=0.45)->ScreenFade:
	if current and is_instance_valid(current):
		current.queue_free()
	var fade := ScreenFade.new()
	fade.target_scene=scene
	fade.fade_color=color
	fade.fade_out_time=out_time
	fade.fade_in_time=in_time
	#挂到根节点上：切场景只会销毁 current_scene，不会销毁它
	(Engine.get_main_loop() as SceneTree).root.add_child(fade)
	return fade

func _ready() -> void:
	layer=128
	process_mode=Node.PROCESS_MODE_ALWAYS
	current=self
	rect=ColorRect.new()
	rect.color=Color(fade_color.r,fade_color.g,fade_color.b,0.0)
	rect.mouse_filter=Control.MOUSE_FILTER_IGNORE
	rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(rect)
	_play()

func _play()->void:
	var out := create_tween()
	out.tween_property(rect,"color:a",fade_color.a,fade_out_time)
	await out.finished
	if target_scene:
		get_tree().change_scene_to_packed(target_scene)
	#等新场景真正进树，否则淡入会发生在旧场景上
	await get_tree().process_frame
	await get_tree().process_frame
	var _in := create_tween()
	_in.tween_property(rect,"color:a",0.0,fade_in_time)
	await _in.finished
	current=null
	queue_free()
