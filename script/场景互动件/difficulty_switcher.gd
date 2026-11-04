class_name DifficultySwitcher
extends Node2D

## 主世界的「难度切换」物件。
## 玩家靠近 → 物件上方弹出难度面板；鼠标悬停高亮，点击选中；
## 选中后物件上方的标签显示当前难度。
##
## 面板里的每一块是 DifficultySegment，块自己带 mode_index，
## 父脚本按"块上的 mode_index"判断，不看坐标、不看节点顺序、不看节点名，
## 所以随便挪位置、加一层容器、改名字都不影响选中判定。

## 难度表：index 与 GameEvent.mode_index 一致
const MODE_TABLE := {
	0: { "name": "简单", "color": Color(0.30, 0.78, 0.55) },
	1: { "name": "普通", "color": Color(0.42, 0.55, 0.72) },
	2: { "name": "困难", "color": Color(0.52, 0.36, 0.62) },
	3: { "name": "挑战", "color": Color(0.66, 0.28, 0.30) },
}

static func mode_name(index:int) -> String:
	var data: Dictionary = MODE_TABLE.get(index, {})
	return data.get("name", "未知")

static func mode_color(index:int) -> Color:
	var data: Dictionary = MODE_TABLE.get(index, {})
	return data.get("color", Color(0.5, 0.5, 0.5))

@onready var name_label: Label = $NameLabel
@onready var approach_area: Area2D = $ApproachArea
@onready var panel: Panel = $Panel

var _segments: Array[DifficultySegment] = []
#每块自己的 StyleBox（复制场景里原来的，保留圆角/边距，只改颜色和描边）
var _boxes: Dictionary = {}

func _ready() -> void:
	panel.visible = false
	approach_area.body_entered.connect(_on_approach_body_entered)
	approach_area.body_exited.connect(_on_approach_body_exited)
	#别的地方改了难度（旧界面 / 以后的新入口）时，这里也跟着变
	GameEvent.mode_change.connect(_refresh)
	_collect_segments(panel)
	_refresh()

## 递归找面板里所有 DifficultySegment，按块绑信号（不依赖层级和节点名）
func _collect_segments(node: Node) -> void:
	for child in node.get_children():
		if child is DifficultySegment:
			var seg: DifficultySegment = child
			_segments.append(seg)
			seg.mouse_entered.connect(_on_segment_mouse_entered.bind(seg))
			seg.mouse_exited.connect(_on_segment_mouse_exited.bind(seg))
			seg.gui_input.connect(_on_segment_gui_input.bind(seg))
			var box: StyleBoxFlat = seg.get_theme_stylebox("panel").duplicate()
			seg.add_theme_stylebox_override("panel", box)
			_boxes[seg] = box
		_collect_segments(child)

#---- 靠近：显示 / 隐藏面板 ----
func _on_approach_body_entered(body: Node2D) -> void:
	if body is Player:
		panel.visible = true
		_refresh()

func _on_approach_body_exited(body: Node2D) -> void:
	if body is Player:
		panel.visible = false

#---- 鼠标 ----
func _on_segment_mouse_entered(seg: DifficultySegment) -> void:
	_apply_style(seg, true)

func _on_segment_mouse_exited(seg: DifficultySegment) -> void:
	_apply_style(seg, false)

func _on_segment_gui_input(event: InputEvent, seg: DifficultySegment) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		GameEvent.select_mode(seg.mode_index)
		_refresh()

#---- 刷新标签与三/四块的样式 ----
func _refresh() -> void:
	var current := GameEvent.mode_index
	if current < 0:
		current = 1
	name_label.text = mode_name(current)
	name_label.modulate = mode_color(current).lightened(0.4)
	for seg in _segments:
		_apply_style(seg, false)

## 一块的三种状态：普通 / 悬停 / 选中
func _apply_style(seg: DifficultySegment, hovered: bool) -> void:
	if ! _boxes.has(seg):
		return
	var base := mode_color(seg.mode_index)
	var selected: bool = seg.mode_index == GameEvent.mode_index
	var box: StyleBoxFlat = _boxes[seg]
	if hovered:
		box.bg_color = base.lightened(0.35)
	elif selected:
		box.bg_color = base
	else:
		box.bg_color = base.darkened(0.55)
	var width := 2 if selected else 0
	box.border_width_left = width
	box.border_width_top = width
	box.border_width_right = width
	box.border_width_bottom = width
	box.border_color = Color(1, 1, 1, 0.95)
	seg.pivot_offset = seg.size / 2
	seg.scale = Vector2(1.06, 1.06) if hovered else Vector2.ONE
