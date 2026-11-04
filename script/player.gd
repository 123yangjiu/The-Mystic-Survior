extends CharacterBody2D
class_name Player

@onready var wound_component: WoundComponent = $WoundComponent
@onready var health_component: HealthComponent = $health_component

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var health_bar: ProgressBar = $HealthBar

@onready var all_gun_ability_controller: AllGunAbilityController = $abilitymanager/AllGunAbilityController
@onready var light_ability_controller: Node2D = $abilitymanager/light_ability_controller

@onready var camera_2d: Camera2D = $Camera2D

@export var died_screen:PackedScene

#---- 被传送门吸走 ----
@export var suck_time:=0.55      # 立绘被吸进门里要多久（和 portal 的进入动画配合）

var is_sucked:=false



var direction:=Vector2(0,0)
var vec:Vector2
var is_run:=false:set=set_is_run
#手机移动
var is_touch:=false


func _ready() -> void:
	#添加分组
	add_to_group("player")
	#初始化血量为满血
	health_bar.value=health_component.get_health_persent()
	#血条只在一局游戏里显示（大厅里藏着）：is_start 已经是"现在是不是在一局里"的唯一判据，
	#begin_run()/end_run() 在切场景之前就把这个值设好了，所以这里直接读就行，不用再加开关
	health_bar.visible=GameEvent.is_start

	GameEvent.blood_bottle_collected.connect(on_blood_bottle_collected)
	GameEvent.ability_upgrade_add.connect(on_ability_upgrade_add)
	health_component.health_change.connect(on_health_change)
	health_component.died.connect(on_died)
	
	#混乱状态测试
	#var _confusion := preload("res://scene/status_effect/confusion_effect.tscn").instantiate() as EffectConfusion
#
	#_confusion.attach_effect(self,5)

@export var MAX_speed=120
func _physics_process(_delta: float) -> void:
	GameEvent.play_global_position=global_position
	#被传送门吸走的时候不再接受操控，原地不动（等切场景）
	if is_sucked:
		velocity=Vector2.ZERO
		return
	if !is_touch:
		direction=get_move_direction().normalized()
	velocity=direction*MAX_speed
	if direction.length() != 0.0:
		is_run=true
	else:
		is_run=false
	move_and_slide()
	if direction.x<0:
		animated_sprite_2d.offset.x=0.0
		animated_sprite_2d.flip_h=false
		GameEvent.play_right=false
	if direction.x>0:
		animated_sprite_2d.offset.x=-4.0
		animated_sprite_2d.flip_h=true
		light_ability_controller.scale.x=1
		GameEvent.play_right=true

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

func on_health_change():
	health_bar.value=health_component.get_health_persent()

func on_died()->void:
	GameEvent.player_died.emit()
	var screen=died_screen.instantiate()
	get_viewport().add_child(screen)

func on_blood_bottle_collected(blood:int):
	health_component.current_health=min(health_component.max_health,health_component.current_health+blood)
	on_health_change()

func on_ability_upgrade_add(upgrade:AbilityUpgrade,_current_upgrade:Dictionary):
	if upgrade.ID=="盔甲":
		var percent = wound_component.current_wound_degree*0.08
		wound_component.wound_degree -=percent
		health_component.max_health*=1.1
		health_component.current_health*=1.1
	if upgrade.ID=="飞毛腿":
		MAX_speed*=1.15

## 被传送门吸进去：交出操控权，立绘边转边缩小、飞向传送门中心并淡出。
## 这是个协程，传送门那边 await 它，等吸完了再切场景。
func be_sucked(target_position:Vector2) -> void:
	if is_sucked:
		return
	is_sucked=true
	direction=Vector2.ZERO
	velocity=Vector2.ZERO
	is_run=false
	#停掉能力和摇杆，免得被吸走的半秒钟还在放技能 / 显示摇杆
	var ability_manager := get_node_or_null("abilitymanager")
	if ability_manager:
		ability_manager.process_mode=Node.PROCESS_MODE_DISABLED
	var player_ui := get_node_or_null("CanvasLayer")
	if player_ui:
		player_ui.visible=false
	#被吸的时候立绘画在传送门上面，否则会被门和粒子挡住
	animated_sprite_2d.z_index=10
	#立绘要用“传送门中心”这个全局坐标算出一个本地偏移，才能飞进门里
	var target_local := target_position-global_position
	var base_scale := animated_sprite_2d.scale
	var tween := create_tween().set_parallel()
	#越吸越快：EASE_IN 让转速和缩小在最后一刻达到最大
	tween.tween_property(animated_sprite_2d,"rotation",TAU,suck_time).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(animated_sprite_2d,"scale",base_scale*0.05,suck_time).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(animated_sprite_2d,"position",target_local,suck_time).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	#透明度用 CUBIC 缓入：前面几乎不透明，最后一小段才迅速消失
	tween.tween_property(animated_sprite_2d,"modulate:a",0.1,suck_time).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	await tween.finished