extends Control

# 按等级顺序排列的节点数组（从低到高）
@export var level_nodes: Array[Control] = []

func _ready():
	# 初始显示最低等级（索引0）
	#show_level(0)
	pass

# 显示指定等级，隐藏其他所有等级
func show_level(level_index: int):
	# 参数合法性检查
	if level_index < 0 or level_index >= level_nodes.size():
		return
	# 遍历所有节点
	for i in range(level_nodes.size()):
		if level_nodes[i]:
			# 只有索引匹配的节点显示，其他隐藏
			level_nodes[i].visible = (i == level_index)

# 解锁等级（直接调用show_level即可）
func unlock_level(level_index: int):
	show_level(level_index)
