class_name FloatingTextPool
extends RefCounted

## 飘字对象池。
##
## 战斗后期只要受到伤害就会弹一个飘字，原来每次都是 instantiate + queue_free：
## 高峰期一帧要新建十几个节点，每个都要走“创建对象 → 实例化脚本 → 进场景树 → 建 Tween → 销毁”这一整套。
## 改成复用之后，同一个节点只创建一次，之后只是“亮出来 → 播动画 → 藏起来”。
##
## 池子挂在“前景图层”这个节点自己的 metadata 上（不是全局静态字典），
## 所以切场景时池子跟着图层一起消失，不会留下指向已释放节点的野引用。

const SCENE := preload("res://scene/ui/floatingtext.tscn")
const POOL_META := &"floating_text_pool"
const MAX_CACHED := 96          # 池子里最多留多少个，防止极端情况一直涨

## 调试用计数：实际弹了多少次、其中多少次是复用、一共新建过几个节点
static var total_spawned:=0
static var total_reused:=0
static var total_created:=0

## 在 layer（一般是 game.scn 的“前景图层”）的 position 处弹一个飘字
static func spawn(layer:Node, position:Vector2, text:String) -> void:
	if ! layer:
		return
	total_spawned+=1
	var pool := _pool_of(layer)
	while ! pool.is_empty():
		var node = pool.pop_back()
		if ! is_instance_valid(node):
			continue
		var _node := node as Node2D
		_node.global_position=position
		_node.scale=Vector2.ONE
		_node.modulate.a=1.0
		_node.visible=true
		_node.start(text)
		total_reused+=1
		return
	#池子空了才新建
	var node := SCENE.instantiate() as Node2D
	layer.add_child(node)
	node.global_position=position
	node.start(text)
	total_created+=1

## 飘字播完动画后调用：藏起来放回池子；池子满了就直接销毁
static func recycle(node:Node2D) -> void:
	var layer := node.get_parent()
	if ! layer:
		node.queue_free()
		return
	var pool := _pool_of(layer)
	if pool.size()>=MAX_CACHED:
		node.queue_free()
		return
	node.visible=false
	node.scale=Vector2.ONE
	node.modulate.a=1.0
	pool.append(node)

static func _pool_of(layer:Node) -> Array:
	if layer.has_meta(POOL_META):
		return layer.get_meta(POOL_META)
	var pool:Array=[]
	layer.set_meta(POOL_META,pool)
	return pool