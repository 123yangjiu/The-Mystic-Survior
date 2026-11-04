class_name DifficultySegment
extends Panel

## 一块难度色块。每块自己记住对应的难度（mode_index），
## 父脚本只认这个值 —— 所以换位置、换容器、改节点名都不影响判定。

@export var mode_index:int = 1
## 是否由脚本自动把 Label 的文字设成难度名（关掉就可以自己写文字/放美术）
@export var auto_label:bool = true

func _ready() -> void:
	if auto_label:
		set_label_text()

func set_label_text() -> void:
	var label := get_node_or_null("Label") as Label
	if label:
		label.text = DifficultySwitcher.mode_name(mode_index)
