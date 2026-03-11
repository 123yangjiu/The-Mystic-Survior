extends AgainstThing
@onready var huijian: AudioStreamPlayer2D = $挥剑
@onready var huiji: AudioStreamPlayer2D = $汇集

var is_follow:=true
var is_right:=false

#自动化
var target_right:=false

@onready var rigth_top: Node2D = $RigthTop
@onready var left_down: Node2D = $LeftDown
@onready var zuo_rigth_top: Node2D = $ZuoRigthTop
@onready var zuo_left_down: Node2D = $ZuoLeftDown


func _ready() -> void:
	if ! GameEvent.play_right:
		scale.x =-abs(scale.x)
		is_right =false
	else :
		is_right=true

func _physics_process(_delta: float) -> void:
	if is_follow:
		global_position=GameEvent.play_global_position+Vector2(0.0,-21.0)

func flip()->void:
	check_enemy()
	#管理光剑长度
	var real_scale = scale.y
	scale.y=abs(scale.x)
	scale.x=real_scale
	is_follow=false
	#管理光剑自动转向
	if GameEvent.is_light_auto:
		if target_right!=is_right:
			if target_right:
				scale.x =abs(scale.x)
				scale.y *=-1
				global_position=GameEvent.play_global_position+Vector2(0.0,21.0)
			else :
				scale.x =-abs(scale.x)
				scale.y *=-1
				global_position=GameEvent.play_global_position+Vector2(0.0,21.0)
			return
	#手操转向
	if ! GameEvent.play_right:
		scale.x =- abs(scale.x)
		if is_right:
			scale.y *=-1
			global_position=GameEvent.play_global_position+Vector2(0.0,21.0)
	else :
		scale.x =abs(scale.x)
		if ! is_right:
			scale.y *=-1
			global_position=GameEvent.play_global_position+Vector2(0.0,21.0)

func check_enemy()->void:
	var enemies:Array[Node]= get_tree().get_first_node_in_group("enemylayer").get_children()
	var enemies_2 = enemies.duplicate(true)
	if is_right:
		enemies=enemies.filter(func(enemy:Node2D):#过滤掉不在范围内的敌人
			var is_true := enemy.global_position.y >rigth_top.global_position.y
			var is_true2 :=enemy.global_position.y < left_down.global_position.y
			var is_truex:=enemy.global_position.x >left_down.global_position.x
			var is_truex2 := enemy.global_position.x < rigth_top.global_position.x
			return  is_true and is_true2 and is_truex and is_truex2
		)
		enemies_2=enemies_2.filter(func(enemy:Node2D):#过滤掉不在范围内的敌人
			var is_true := enemy.global_position.y >zuo_rigth_top.global_position.y
			var is_true2 :=enemy.global_position.y < zuo_left_down.global_position.y
			var is_truex:=enemy.global_position.x >zuo_left_down.global_position.x
			var is_truex2 := enemy.global_position.x < zuo_rigth_top.global_position.x
			return  is_true and is_true2 and is_truex and is_truex2
		)
	else :
		enemies=enemies.filter(func(enemy:Node2D):#过滤掉不在范围内的敌人
			var is_true := enemy.global_position.y >rigth_top.global_position.y
			var is_true2 :=enemy.global_position.y < left_down.global_position.y
			var is_truex:=enemy.global_position.x <left_down.global_position.x
			var is_truex2 := enemy.global_position.x > rigth_top.global_position.x
			return  is_true and is_true2 and is_truex and is_truex2
		)
		enemies_2=enemies_2.filter(func(enemy:Node2D):#过滤掉不在范围内的敌人
			var is_true := enemy.global_position.y >zuo_rigth_top.global_position.y
			var is_true2 :=enemy.global_position.y < zuo_left_down.global_position.y
			var is_truex:=enemy.global_position.x <zuo_left_down.global_position.x
			var is_truex2 := enemy.global_position.x > zuo_rigth_top.global_position.x
			return  is_true and is_true2 and is_truex and is_truex2
		)
	var enemies_size = enemies.size()
	var enemies_2_size = enemies_2.size()
	if enemies_size>=enemies_2_size:
		if is_right:
			target_right=true
		else :
			target_right=false
	else:
		if is_right:
			target_right=false
		else :
			target_right=true
