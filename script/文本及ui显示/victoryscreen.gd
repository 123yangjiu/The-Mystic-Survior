extends CanvasLayer
@export var tips: Label

var tips_array:Array[String] =[
	"想要获取同一种能力五次是十分困难的哦（但也并非不可能",
	"骑士冲锋看着很吓人，实际上当他冲到你时他就会在短时间内保持原速不转向，所以直接用脸接也是氵",
	"告诉你个秘密，这游戏的地图其实...很大",
	"当你选能力时可以用空格代替鼠标，左右键转换选项，也就是说——这鼠标不要也罢",
	"尽量不要站在怪群的下方，要不然他们就要依靠奇怪的动能创思你了(",
	"这游戏其实会在怪特别多时减少刷怪的，也就是说刷怪越多，刷怪越少",
	"女主收到伤害后会有短暂的无敌——真的很短暂",
	"喜欢这游戏的音乐吗，让我们感谢免费资源创作者们🙏"
]

func _ready() -> void:


	GameEvent.paused+=1
	get_tree().paused = true
	%restart.pressed.connect(on_restart_press)
	%quit.pressed.connect(on_quit_press)
	var index = randi() %tips_array.size()
	var tip = "Tips:"+tips_array.get(index)
	if tips:
		tips.text=tip
	await get_tree().create_timer(0.5).timeout



func on_restart_press():
	await get_tree().create_timer(0.1).timeout
	GameEvent.paused=0
	get_tree().paused= false
	GameEvent.difficulty=1
	GameEvent.the_first=0
	get_tree().change_scene_to_file("res://scene/game.tscn")
	GameEvent.difficulty_timer.start()
	queue_free()
	pass

func  on_quit_press():
	get_tree().quit()
	pass
