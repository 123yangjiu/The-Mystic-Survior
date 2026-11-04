extends Node2D

## 主世界的图鉴终端：玩家靠近显示提示，按空格打开图鉴（打开时暂停游戏）。

@onready var hint: Label = $Hint
@onready var area: Area2D = $Area2D

var _inside := false
var _codex: Node = null

func _ready() -> void:
	hint.visible = false
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		_inside = true
		hint.visible = true

func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		_inside = false
		hint.visible = false

func _unhandled_input(event: InputEvent) -> void:
	if ! _inside or _codex != null:
		return
	if event.is_action_pressed("ui_accept"):
		_open_codex()
		get_viewport().set_input_as_handled()

func _open_codex() -> void:
	_codex = (load("res://scene/ui/图鉴/图鉴.tscn") as PackedScene).instantiate()
	get_tree().root.add_child(_codex)
	_codex.open()
	_codex.tree_exited.connect(_on_codex_closed)

func _on_codex_closed() -> void:
	_codex = null
