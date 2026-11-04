extends CanvasLayer

@onready var tips: Label = $Tips

var tips_array:Array[String] =[
	"同一种能力获取次数越多，想再次获得就越难",
	"告诉你个秘密，这游戏的地图其实...很大",
	"当你选能力时可以用空格代替鼠标，左右键转换选项，也就是说——这鼠标不要也罢",
	"这游戏其实会在怪特别多时减少刷怪的，也就是说刷怪越多，刷怪越少",
	"女主收到伤害后会有短暂的无敌——真的很短暂",
	"喜欢这游戏的音乐吗，让我们感谢免费资源创作者们🙏",
	"狙击枪会锁头人群中伤害最高的靓仔",
	"敌人对你造成伤害会在短时间馁无法转向，所以，向他来的方向跑吧！",
	"每局游戏只会从所有攻击能力里挑4个出来，也就是说，要成为武器大师"
]

func _ready() -> void:
	GameEvent.stop_game()
	var index = randi() %tips_array.size()
	var tip = "Tips:"+tips_array.get(index)
	if tips:
		tips.text=tip
