class_name Codex
extends CanvasLayer

## 图鉴界面（节点版）：布局全在 scene/ui/图鉴/图鉴.tscn 里，这个脚本只负责填数据、切页签。
## 用到的 Control 子类：Control / ColorRect / Panel / PanelContainer / MarginContainer /
## HBoxContainer / VBoxContainer / GridContainer / ScrollContainer / SubViewportContainer /
## SubViewport / TextureRect / Label / Button / VideoStreamPlayer。

const COL_ACCENT := Color(0.40, 0.70, 1.0, 1.0)
const COL_MUTED := Color(0.55, 0.60, 0.70, 1.0)
const COL_TEXT := Color(0.86, 0.90, 0.96, 1.0)

@onready var home: Control = $Root/Home
@onready var page: Control = $Root/Page
@onready var header_title: Label = $Root/Page/Header/Title
@onready var back_button: Button = $Root/Page/Header/Back
@onready var close_button: Button = $Root/Page/Header/Close
@onready var list_scroll: ScrollContainer = $Root/Page/Body/Sidebar/Margin/VBox/Scroll
@onready var list_box: VBoxContainer = $Root/Page/Body/Sidebar/Margin/VBox/Scroll/List
@onready var name_label: Label = $Root/Page/Body/Detail/Margin/VBox/Name
@onready var sub_label: Label = $Root/Page/Body/Detail/Margin/VBox/Sub
@onready var stats_grid: GridContainer = $Root/Page/Body/Detail/Margin/VBox/Top/Stats
@onready var section_label: Label = $Root/Page/Body/Detail/Margin/VBox/Section
@onready var extra_box: VBoxContainer = $Root/Page/Body/Detail/Margin/VBox/Extra/ExtraBox
@onready var stage: Node2D = $Root/Page/Body/Detail/Margin/VBox/Top/Media/MediaPanel/ViewportContainer/StageViewport/Stage
@onready var caption: Label = $Root/Page/Body/Detail/Margin/VBox/Top/Media/Caption
@onready var video: VideoStreamPlayer = $Root/Page/Body/Detail/Margin/VBox/Top/Media/MediaPanel/Video

var mode := ""
var entries: Array[Dictionary] = []
var selected := -1

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 100
	$Root/Home/Skill.pressed.connect(func() -> void: _show_mode("skill"))
	$Root/Home/Enemy.pressed.connect(func() -> void: _show_mode("enemy"))
	back_button.pressed.connect(_show_home)
	close_button.pressed.connect(close)
	_show_home()

func open() -> void:
	visible = true
	get_tree().paused = true
	_show_home()

func close() -> void:
	get_tree().paused = false
	visible = false
	queue_free()

func _unhandled_input(event: InputEvent) -> void:
	if ! visible:
		return
	if event.is_action_pressed("ui_cancel"):
		if home.visible:
			close()
		else:
			_show_home()
		get_viewport().set_input_as_handled()

#---- 切页 ----
func _show_home() -> void:
	home.visible = true
	page.visible = false
	_clear_stage()

func _show_mode(new_mode: String) -> void:
	mode = new_mode
	home.visible = false
	page.visible = true
	header_title.text = "技能图鉴" if mode == "skill" else "敌人图鉴"
	entries = CodexData.all_abilities() if mode == "skill" else CodexData.all_enemies()
	_fill_list()
	list_scroll.scroll_vertical = 0
	if entries.size() > 0:
		_select(0)

func _fill_list() -> void:
	for child in list_box.get_children():
		child.queue_free()
	for i in entries.size():
		var entry: Dictionary = entries[i]
		var btn := Button.new()
		btn.text = String(entry.get("name", "?"))
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.custom_minimum_size = Vector2(0, 23)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.add_theme_font_size_override("font_size", 12)
		btn.add_theme_color_override("font_color", COL_MUTED)
		btn.add_theme_color_override("font_hover_color", COL_TEXT)
		var index := i
		btn.pressed.connect(func() -> void: _select(index))
		list_box.add_child(btn)

func _select(index: int) -> void:
	selected = index
	for i in list_box.get_child_count():
		var btn := list_box.get_child(i) as Button
		btn.add_theme_color_override("font_color", COL_ACCENT if i == index else COL_MUTED)
	_render_detail()

#---- 填详情 ----
func _render_detail() -> void:
	if selected < 0 or selected >= entries.size():
		return
	_clear_detail()
	_clear_stage()
	var entry: Dictionary = entries[selected]
	if mode == "enemy":
		_render_enemy(entry)
	else:
		_render_skill(entry)

func _render_enemy(entry: Dictionary) -> void:
	name_label.text = String(entry.name)
	sub_label.text = String(entry.key)
	_add_stat("血量", _num(entry.hp))
	_add_stat("移动速度", _num(entry.speed))
	_add_stat("接触伤害", _num(entry.damage))
	_add_stat("刷怪权重", _num(entry.weight))
	var unlock := int(entry.unlock)
	_add_stat("出现时间", "只走特殊事件" if unlock < 0 else CodexData.difficulty_to_time(unlock) + "（难度 " + str(unlock) + "）")
	var dis := int(entry.disappear)
	_add_stat("消失时间", "不会消失" if dis >= 100 else CodexData.difficulty_to_time(dis) + "（难度 " + str(dis) + "）")
	section_label.text = "特殊技能"
	var skills: Array = entry.skills
	if skills.is_empty():
		_add_extra("没有特殊技能", COL_MUTED)
	else:
		for skill in skills:
			_add_extra("· " + String(skill.name), COL_ACCENT)
			_add_extra(String(skill.desc), COL_MUTED)
	if entry.scene:
		_preview(entry.scene)

func _render_skill(entry: Dictionary) -> void:
	name_label.text = String(entry.name)
	var subtitle := String(entry.get("sort", ""))
	if entry.has("flavor"):
		subtitle += "  ·  " + String(entry.flavor)
	sub_label.text = subtitle
	if entry.get("active", false):
		_add_stat("伤害", String(entry.get("damage_text", "—")))
		_add_stat("攻击间隔", String(entry.get("interval_text", "—")))
		_add_stat("升级卡", str(CodexData.upgrade_cards(String(entry.sort)).size()) + " 张")
		var maxed := CodexData.max_stats(entry)
		_add_stat("满级伤害", String(maxed.get("text", "%.0f" % float(maxed.get("damage", 0.0)))))
		if ! maxed.has("text"):
			_add_stat("满级间隔", "%.2f 秒" % float(maxed.get("interval", 0.0)))
		section_label.text = "升级效果（每张卡最多 4 次）"
		var cards := CodexData.upgrade_cards(String(entry.sort))
		if cards.is_empty():
			_add_extra("没有升级卡", COL_MUTED)
		else:
			for card in cards:
				_add_extra("· " + String(card.id) + "（" + String(card.name) + "）", COL_ACCENT)
				_add_extra(String(card.desc), COL_MUTED)
		for note in maxed.get("notes", []):
			_add_extra("· " + String(note), COL_MUTED)
	else:
		_add_stat("类型", "角色能力（被动）")
		section_label.text = "效果"
		_add_extra(String(entry.desc), COL_TEXT)
	var ability: PackedScene = entry.get("ability")
	var video_path := String(entry.get("video", ""))
	if video_path != "" and ResourceLoader.exists(video_path):
		video.stream = load(video_path)
		video.visible = true
		video.play()
		caption.text = "演示"
	elif ability:
		_preview(ability)
	else:
		caption.text = "演示视频待补充"

#---- 组件 ----
func _add_stat(key: String, value: String) -> void:
	var key_label := Label.new()
	key_label.text = key
	key_label.custom_minimum_size = Vector2(56, 0)
	key_label.add_theme_font_size_override("font_size", 12)
	key_label.add_theme_color_override("font_color", COL_MUTED)
	stats_grid.add_child(key_label)
	var value_label := Label.new()
	value_label.text = value
	value_label.custom_minimum_size = Vector2(150, 0)
	value_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	value_label.add_theme_font_size_override("font_size", 12)
	value_label.add_theme_color_override("font_color", COL_TEXT)
	stats_grid.add_child(value_label)

func _add_extra(text: String, color: Color) -> void:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.add_theme_font_size_override("font_size", 12)
	label.add_theme_color_override("font_color", color)
	extra_box.add_child(label)

func _preview(scene: PackedScene) -> void:
	var node := CodexData.preview(scene, 96)
	stage.add_child(node)
	caption.text = "攻击动画" if mode == "skill" else "移动动画"

func _clear_detail() -> void:
	for child in stats_grid.get_children():
		child.queue_free()
	for child in extra_box.get_children():
		child.queue_free()
	section_label.text = ""
	name_label.text = ""
	sub_label.text = ""

func _clear_stage() -> void:
	video.stop()
	video.visible = false
	for child in stage.get_children():
		child.queue_free()
	caption.text = ""

func _num(value) -> String:
	return "—" if value == null else str(int(value))
