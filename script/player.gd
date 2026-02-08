extends CharacterBody2D
class_name Player
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var health_component: HealthComponent = $health_component
@onready var health_bar: ProgressBar = $HealthBar
@export var died_screen:PackedScene

var enter_body_number_10=0
var enter_body_number_17=0
var enter_body_number_30=0
var enter_body_number_47=0
var rad_hurt=randf_range(-3,3)

var enter_body_number_10_hurt=10
var enter_body_number_17_hurt=15
var enter_body_number_30_hurt=25
var enter_body_number_47_hurt=40


var direction:=Vector2(0,0)
var vec:Vector2
var is_run:=false:set=set_is_run
#手机移动
var is_touch:=false
func _ready() -> void:
	# ① 形状是否存在
	GameEvent.ability_upgrade_add.connect(on_ability_upgrade_add)
	add_to_group("player")
	$hurtrange.body_entered.connect(on_body_enter)
	$hurtrange.body_exited.connect(on_body_exited)
	$"伤害间隔计时器".timeout.connect(on_time_out)
	health_component.health_change.connect(on_health_change)#当血量
	health_component.died.connect(on_died)
	#改变实时发出信号让血条实时变化
	health_bar.value=health_component.get_health_persent()#初始化血量为满血
	GameEvent.blood_bottle_collected.connect(on_blood_bottle_collected)
	if ! GameEvent.is_hard:
		enter_body_number_10_hurt=6
		enter_body_number_17_hurt=10
		enter_body_number_30_hurt=15
		enter_body_number_47_hurt=20
	else :
		enter_body_number_10_hurt=10
		enter_body_number_17_hurt=15
		enter_body_number_30_hurt=25
		enter_body_number_47_hurt=40
		
	
@export var MAX_speed=120
func _physics_process(_delta: float) -> void:
	GameEvent.play_global_position=global_position
	if !is_touch:
		direction=get_move_direction().normalized()
	velocity=direction*MAX_speed
	if direction.length() != 0.0:
		is_run=true
	else:
		is_run=false
	move_and_slide()
	if direction.x<0:
		animated_sprite_2d.flip_h=false
	if direction.x>0:
		animated_sprite_2d.flip_h=true
func set_is_run(value)->void:
	if is_run!= value:
		match value:
			true:
				animated_sprite_2d.play()
			false:
				animated_sprite_2d.stop()
	is_run=value
func get_move_direction():
	var movement_x=Input.get_action_strength("right")-Input.get_action_strength("left")
	var movement_y=Input.get_action_strength("down")-Input.get_action_strength("up")
	return Vector2(movement_x,movement_y)

func on_body_enter(enterbody:Node2D):
	if enterbody.is_in_group("初级"):
		enter_body_number_10+=1
	if enterbody.is_in_group("中级"):
		enter_body_number_17+=1
	if enterbody.is_in_group("高级"):
		enter_body_number_30+=1
	if enterbody.is_in_group("终极"):
		enter_body_number_47+=1
	damage_manager()#有新的敌人进入立刻造成伤害
	var ori_acceleration = enterbody.velocity_component.acceleration
	if ori_acceleration !=0:
		enterbody.velocity_component.acceleration =1
		await get_tree().create_timer(1).timeout
		if enterbody:
			if enterbody.velocity_component.acceleration ==1:
				enterbody.velocity_component.acceleration=ori_acceleration
			if enterbody is Knight:
				enterbody.冲刺范围.end_rush()

func on_body_exited(enterbody:Node2D):

	if enterbody.is_in_group("初级"):
		enter_body_number_10-=1
	if enterbody.is_in_group("中级"):
		enter_body_number_17-=1
	if enterbody.is_in_group("高级"):
		enter_body_number_30-=1
	if enterbody.is_in_group("终极"):
		enter_body_number_47-=1


func damage_manager():
	var totle_nmber=enter_body_number_10+enter_body_number_17+enter_body_number_30\
	+enter_body_number_47
	if totle_nmber==0||!$"伤害间隔计时器".is_stopped():
		return
	#var Demage= enter_body_numbeaar*1
	health_component.damage(enter_body_number_10_hurt*enter_body_number_10+\
	enter_body_number_17_hurt*enter_body_number_17\
	+enter_body_number_30*enter_body_number_30_hurt\
	+enter_body_number_47*enter_body_number_47_hurt+rad_hurt)
	audio_stream_player_2d.play()
	$"伤害间隔计时器".start()


func on_time_out():#没有走出敌人攻击范围就再次造成伤害daw
	damage_manager()

func on_health_change():

	health_bar.value=health_component.get_health_persent()


func on_died()->void:
	GameEvent.player_died.emit()
	var screen=died_screen.instantiate()
	get_viewport().add_child(screen)


func on_blood_bottle_collected(blood:int):
	health_component.current_health=min(health_component.max_health,health_component.current_health+blood)
	on_health_change()

func on_ability_upgrade_add(upgrade:AbilityUpgrade,current_upgrade:Dictionary):
	if upgrade.ID=="盔甲":
		enter_body_number_10_hurt=10*(1-0.07*current_upgrade["盔甲"]["quantity"])
		enter_body_number_17_hurt=17*(1-0.07*current_upgrade["盔甲"]["quantity"])
		enter_body_number_30_hurt=30*(1-0.07*current_upgrade["盔甲"]["quantity"])
		enter_body_number_47_hurt=47*(1-0.07*current_upgrade["盔甲"]["quantity"])
		health_component.max_health*=1.1
		health_component.current_health*=1.1
	if upgrade.ID=="飞毛腿":
		MAX_speed*=1.15
