class_name Codex
extends CanvasLayer

## 全屏图鉴：首页左右两半（左=技能、右=敌人），进去后左边目录、右边详情。
## 数据和动画预览都来自 CodexData，这里只管画界面和切换。

const COL_BG := Color(0.04, 0.05, 0.08, 1.0)
const COL_PANEL := Color(0.10, 0.12, 0.17, 1.0)
const COL_LINE := Color(0.22, 0.27, 0.35, 1.0)
const COL_TEXT := Color(0.86, 0.90, 0.96, 1.0)
const COL_MUTED := Color(0.55, 0.60, 0.70, 1.0)
const COL_ACCENT := Color(0.40, 0.70, 1.0, 1.0)
const COL_HOVER := Color(0.16, 0.22, 0.32, 1.0)

var mode := ""
var entries: Array[Dictionary] = []
var selected := -1

var home: Control
var page: Control
var list_box: VBoxContainer
var detail_box: VBoxContainer
var page_title: Label
var media_holder: Control
var stage: Node2D
var media_label: Label
var video_player: VideoStreamPlayer

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 100
	_build_home()
	_build_page()
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

#---- 首页 ----
func _build_home() -> void:
	var dim := ColorRect.new()
	dim.color = COL_BG
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(dim)

	home = Control.new()
	home.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(home)

	var title := _label("图  鉴", 22, COL_TEXT)
	title.position = Vector2(0, 26)
	title.size = Vector2(640, 30)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	home.add_child(title)

	var hint := _label("左边看技能，右边看敌人    ·    Esc 关闭", 12, COL_MUTED)
	hint.position = Vector2(0, 58)
	hint.size = Vector2(640, 20)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	home.add_child(hint)

	home.add_child(_big_button("技能图鉴", "所有能力与升级效果", Rect2(40, 92, 260, 206), Color(0.25, 0.55, 0.95), func() -> void: _show_mode("skill")))
	home.add_child(_big_button("敌人图鉴", "敌人属性与特殊技能", Rect2(340, 92, 260, 206), Color(0.85, 0.45, 0.3), func() -> void: _show_mode("enemy")))

#---- 详情页 ----
func _build_page() -> void:
	page = Control.new()
	page.set_anchors_preset(Control.PRESET_FULL_RECT)
	page.visible = false
	add_child(page)

	var bg := ColorRect.new()
	bg.color = COL_BG
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	page.add_child(bg)

	page_title = _label("", 14, COL_TEXT)
	page_title.position = Vector2(12, 6)
	page_title.size = Vector2(300, 22)
	page.add_child(page_title)
	page.add_child(_small_button("← 返回", Rect2(478, 6, 72, 22), func() -> void: _show_home()))
	page.add_child(_small_button("×", Rect2(604, 6, 26, 22), func() -> void: close()))

	var side := Panel.new()
	side.position = Vector2(8, 34)
	side.size = Vector2(196, 318)
	side.add_theme_stylebox_override("panel", _box(COL_PANEL, COL_LINE))
	page.add_child(side)

	var scroll := ScrollContainer.new()
	scroll.position = Vector2(12, 38)
	scroll.size = Vector2(188, 310)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	page.add_child(scroll)
	list_box = VBoxContainer.new()
	list_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list_box.add_theme_constant_override("separation", 2)
	scroll.add_child(list_box)

	var detail_panel := Panel.new()
	detail_panel.position = Vector2(212, 34)
	detail_panel.size = Vector2(420, 318)
	detail_panel.add_theme_stylebox_override("panel", _box(COL_PANEL, COL_LINE))
	page.add_child(detail_panel)

	var detail_scroll := ScrollContainer.new()
	detail_scroll.position = Vector2(220, 40)
	detail_scroll.size = Vector2(280, 306)
	detail_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	page.add_child(detail_scroll)
	detail_box = VBoxContainer.new()
	detail_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	detail_box.add_theme_constant_override("separation", 2)
	detail_scroll.add_child(detail_box)

	media_holder = Control.new()
	media_holder.position = Vector2(508, 40)
	media_holder.size = Vector2(116, 116)
	page.add_child(media_holder)
	var media_box := Panel.new()
	media_box.position = Vector2.ZERO
	media_box.size = Vector2(116, 116)
	media_box.add_theme_stylebox_override("panel", _box(Color(0.07, 0.09, 0.13, 1), COL_LINE))
	media_holder.add_child(media_box)
	stage = Node2D.new()
	stage.position = Vector2(58, 58)
	stage.process_mode = Node.PROCESS_MODE_ALWAYS
	media_holder.add_child(stage)
	media_label = _label("", 9, COL_MUTED)
	media_label.position = Vector2(-2, 96)
	media_label.size = Vector2(120, 26)
	media_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	media_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	media_holder.add_child(media_label)
	video_player = VideoStreamPlayer.new()
	video_player.position = Vector2(2, 2)
	video_player.size = Vector2(112, 112)
	video_player.visible = false
	media_holder.add_child(video_player)

func _show_home() -> void:
	home.visible = true
	page.visible = false
	_clear_stage()

func _show_mode(new_mode: String) -> void:
	mode = new_mode
	home.visible = false
	page.visible = true
	page_title.text = "技能图鉴" if mode == "skill" else "敌人图鉴"
	entries = CodexData.all_abilities(get_tree()) if mode == "skill" else CodexData.all_enemies()
	_fill_list()
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
		btn.custom_minimum_size = Vector2(180, 23)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.add_theme_font_size_override("font_size", 11)
		btn.add_theme_color_override("font_color", COL_MUTED)
		btn.add_theme_color_override("font_hover_color", COL_TEXT)
		var normal := _box(Color(0, 0, 0, 0), Color(0, 0, 0, 0))
		normal.content_margin_left = 8
		normal.content_margin_right = 6
		btn.add_theme_stylebox_override("normal", normal)
		var hover := _box(COL_HOVER, Color(0, 0, 0, 0))
		hover.content_margin_left = 8
		hover.content_margin_right = 6
		btn.add_theme_stylebox_override("hover", hover)
		btn.add_theme_stylebox_override("pressed", hover)
		var index := i
		btn.pressed.connect(func() -> void: _select(index))
		list_box.add_child(btn)

func _select(index: int) -> void:
	selected = index
	for i in list_box.get_child_count():
		var btn := list_box.get_child(i) as Button
		btn.add_theme_color_override("font_color", COL_ACCENT if i == index else COL_MUTED)
	_render_detail()

func _render_detail() -> void:
	if selected < 0 or selected >= entries.size():
		return
	for child in detail_box.get_children():
		child.queue_free()
	_clear_stage()
	var entry: Dictionary = entries[selected]
	if mode == "enemy":
		_render_enemy(entry)
	else:
		_render_skill(entry)

func _render_enemy(entry: Dictionary) -> void:
	_add_to_detail(_label(String(entry.name), 17, COL_TEXT))
	_add_to_detail(_label(String(entry.key), 9, COL_MUTED))
	_add_to_detail(_spacer(4))
	var grid := _grid()
	_grid_row(grid, "血量", _num(entry.hp))
	_grid_row(grid, "移动速度", _num(entry.speed))
	_grid_row(grid, "接触伤害", _num(entry.damage))
	_grid_row(grid, "刷怪权重", _num(entry.weight))
	var unlock := int(entry.unlock)
	var appear := "只走特殊事件"
	if unlock >= 0:
		appear = CodexData.difficulty_to_time(unlock) + "（难度 " + str(unlock) + "）"
	_grid_row(grid, "出现时间", appear)
	var dis := int(entry.disappear)
	var gone := "不会消失"
	if dis < 100:
		gone = CodexData.difficulty_to_time(dis) + "（难度 " + str(dis) + "）"
	_grid_row(grid, "消失时间", gone)
	_add_to_detail(grid)
	_add_to_detail(_spacer(6))
	_add_to_detail(_section("特殊技能"))
	var skills: Array = entry.skills
	if skills.is_empty():
		_add_to_detail(_label("没有特殊技能", 10, COL_MUTED))
	else:
		for skill in skills:
			_add_to_detail(_label("· " + String(skill.name), 11, COL_ACCENT))
			var desc := _label(String(skill.desc), 10, COL_MUTED)
			desc.custom_minimum_size = Vector2(266, 0)
			_add_to_detail(desc)
	if entry.scene:
		_add_stage(CodexData.preview(entry.scene, 92), "移动动画")

func _render_skill(entry: Dictionary) -> void:
	_add_to_detail(_label(String(entry.name), 17, COL_TEXT))
	var subtitle := String(entry.get("sort", ""))
	if entry.has("flavor"):
		subtitle += "  ·  " + String(entry.flavor)
	_add_to_detail(_label(subtitle, 9, COL_MUTED))
	_add_to_detail(_spacer(4))
	var grid := _grid()
	if entry.get("active", false):
		_grid_row(grid, "伤害", String(entry.get("damage_text", "—")))
		_grid_row(grid, "攻击间隔", String(entry.get("interval_text", "—")))
		_grid_row(grid, "升级卡", str(CodexData.upgrade_cards(String(entry.sort)).size()) + " 张")
		_add_to_detail(grid)
		var maxed := CodexData.max_stats(entry)
		_add_to_detail(_spacer(6))
		_add_to_detail(_section("满级（每张卡选 4 次）"))
		if maxed.has("text"):
			_add_to_detail(_label(String(maxed.text), 10, COL_TEXT))
		else:
			var mgrid := _grid()
			_grid_row(mgrid, "伤害", "%.0f" % float(maxed.damage))
			_grid_row(mgrid, "攻击间隔", "%.2f 秒" % float(maxed.interval))
			_add_to_detail(mgrid)
			for note in maxed.get("notes", []):
				_add_to_detail(_label("· " + String(note), 10, COL_MUTED))
	else:
		_grid_row(grid, "类型", "角色能力（被动）")
		_add_to_detail(grid)
		_add_to_detail(_spacer(4))
		var desc_label := _label(String(entry.desc), 10, COL_TEXT)
		desc_label.custom_minimum_size = Vector2(266, 0)
		_add_to_detail(desc_label)
	if entry.get("active", false):
		_add_to_detail(_spacer(6))
		_add_to_detail(_section("升级效果"))
		var cards := CodexData.upgrade_cards(String(entry.sort))
		if cards.is_empty():
			_add_to_detail(_label("没有升级卡", 10, COL_MUTED))
		else:
			for card in cards:
				_add_to_detail(_label("· " + String(card.id) + "（" + String(card.name) + "）", 11, COL_ACCENT))
				var desc := _label(String(card.desc), 10, COL_MUTED)
				desc.custom_minimum_size = Vector2(266, 0)
				_add_to_detail(desc)
	var ability: PackedScene = entry.get("ability")
	var video_path := String(entry.get("video", ""))
	if video_path != "" and ResourceLoader.exists(video_path):
		video_player.stream = load(video_path)
		video_player.visible = true
		video_player.play()
		media_label.text = "演示"
	elif ability:
		_add_stage(CodexData.preview(ability, 92), "攻击动画")
	else:
		media_label.text = "演示视频待补充"

#---- 小工具 ----
func _num(value) -> String:
	return "—" if value == null else str(int(value))

func _grid() -> GridContainer:
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 10)
	grid.add_theme_constant_override("v_separation", 3)
	return grid

func _grid_row(grid: GridContainer, key: String, value: String) -> void:
	var key_label := _label(key, 10, COL_MUTED)
	key_label.custom_minimum_size = Vector2(58, 0)
	grid.add_child(key_label)
	var value_label := _label(value, 10, COL_TEXT)
	value_label.custom_minimum_size = Vector2(186, 0)
	value_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	grid.add_child(value_label)

func _section(text: String) -> Label:
	var label := _label(text, 12, COL_ACCENT)
	return label

func _spacer(height: float) -> Control:
	var ctrl := Control.new()
	ctrl.custom_minimum_size = Vector2(0, height)
	return ctrl

func _add_to_detail(node: Control) -> void:
	detail_box.add_child(node)

func _label(text: String, size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return label

func _box(bg: Color, border: Color) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = bg
	box.border_color = border
	box.border_width_left = 1 if border.a > 0 else 0
	box.border_width_top = 1 if border.a > 0 else 0
	box.border_width_right = 1 if border.a > 0 else 0
	box.border_width_bottom = 1 if border.a > 0 else 0
	box.corner_radius_top_left = 4
	box.corner_radius_top_right = 4
	box.corner_radius_bottom_left = 4
	box.corner_radius_bottom_right = 4
	return box

func _small_button(text: String, rect: Rect2, callback: Callable) -> Button:
	var btn := Button.new()
	btn.text = text
	btn.position = rect.position
	btn.size = rect.size
	btn.add_theme_font_size_override("font_size", 11)
	btn.add_theme_color_override("font_color", COL_TEXT)
	btn.add_theme_color_override("font_hover_color", Color.WHITE)
	btn.add_theme_stylebox_override("normal", _box(COL_PANEL, COL_LINE))
	btn.add_theme_stylebox_override("hover", _box(COL_HOVER, COL_LINE))
	btn.add_theme_stylebox_override("pressed", _box(COL_HOVER, COL_LINE))
	btn.pressed.connect(callback)
	return btn

func _big_button(title: String, subtitle: String, rect: Rect2, accent: Color, callback: Callable) -> Button:
	var btn := Button.new()
	btn.position = rect.position
	btn.size = rect.size
	btn.text = title + "\n" + subtitle
	btn.add_theme_font_size_override("font_size", 16)
	btn.add_theme_color_override("font_color", COL_TEXT)
	btn.add_theme_color_override("font_hover_color", Color.WHITE)
	btn.add_theme_stylebox_override("normal", _box(COL_PANEL, accent))
	btn.add_theme_stylebox_override("hover", _box(COL_HOVER, accent))
	btn.add_theme_stylebox_override("pressed", _box(Color(accent.r, accent.g, accent.b, 0.35), accent))
	btn.pressed.connect(callback)
	return btn

func _add_stage(preview: Node2D, caption: String) -> void:
	stage.add_child(preview)
	media_label.text = caption

func _clear_stage() -> void:
	video_player.stop()
	video_player.visible = false
	for child in stage.get_children():
		child.queue_free()
	media_label.text = ""
