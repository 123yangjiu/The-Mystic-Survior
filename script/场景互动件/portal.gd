class_name Portal
extends Node2D

## 传送门“长什么样”的部分：待机呼吸、有人靠近时醒来、进入时收缩 + 爆发。
## 这里只管外观，谁可以进入、进入之后去哪里，交给子类（见 player_portal.gd）。
##
## 节点约定（缺了哪个就自动跳过，方便做不同版本的传送门）：
##   AnimatedSprite2D  门主体，idle / open / close 三个动画
##   Glow              圆形光晕（径向渐变 + 加色混合，见 portal.tscn）
##   AuraRing          一圈光点，待机时慢慢转
##   PulseRing         每隔几秒往外扩一圈的冲击波（同一张光点图）
##   Effects           下面挂着若干 GPUParticles2D（火星、浮尘、旋流）
##   Burst             进入瞬间炸开的一次性粒子

#---- 手感参数：想调整传送门的呼吸、发光、粒子，改这里 ----
@export_group("待机")
@export var breath_scale:=0.03      # 呼吸时缩放的最大偏移，0.03 = 放大 3%
@export var breath_time:=1.6        # 一次完整呼吸的秒数
@export var breath_glow:=0.08       # 呼吸时光晕明暗的变化量
@export var aura_speed:=20.0        # 光环每秒转多少度
@export var pulse_time:=2.6         # 每隔几秒往外扩一圈冲击波

@export_group("靠近")
@export var wake_scale:=0.09        # 有角色靠近时门额外放大多少
@export var wake_glow:=0.35         # 有角色靠近时光晕额外变亮多少
@export var wake_time:=0.35         # 从“待机”到“醒来”的过渡时间

@export_group("进入")
@export var enter_time:=0.5         # 进入动画（关门 + 爆发）的时长
@export var enter_ring_scale:=3.4   # 进入时冲击波放大到几倍

@export_group("风格")
@export var theme_color:=Color.WHITE   # 这个门的色调：白色 = 原样，其它颜色会把光晕/粒子染成对应色
@export var portal_name:=""            # 门上方显示的名字（空 = 不显示）

#---- 节点 ----
@onready var body:AnimatedSprite2D = get_node_or_null("AnimatedSprite2D") as AnimatedSprite2D
@onready var glow:Sprite2D = get_node_or_null("Glow") as Sprite2D
@onready var aura_ring:Sprite2D = get_node_or_null("AuraRing") as Sprite2D
@onready var pulse_ring:Sprite2D = get_node_or_null("PulseRing") as Sprite2D
@onready var effects:Node2D = get_node_or_null("Effects") as Node2D
@onready var burst:GPUParticles2D = get_node_or_null("Burst") as GPUParticles2D

var is_leaving:=false     # 已经有人进去了，不再重复触发
var wake:=0.0             # 0 = 待机，1 = 有角色靠近

var _time:=0.0            # 呼吸用的累计时间
var _pulse_t:=0.0         # 冲击波走到哪了（0~pulse_time）
var _body_base:=Vector2.ONE
var _glow_base:=Vector2.ONE
var _aura_base:=Vector2.ONE
var _pulse_base:=Vector2.ONE
var _glow_alpha:=1.0
var _pulse_alpha:=1.0
var _wake_tween:Tween

func _ready() -> void:
	#记下场景里摆好的初始大小和亮度，后面都在这个基础上做动画
	_body_base = body.scale if body else Vector2.ONE
	_glow_base = glow.scale if glow else Vector2.ONE
	_aura_base = aura_ring.scale if aura_ring else Vector2.ONE
	_pulse_base = pulse_ring.scale if pulse_ring else Vector2.ONE
	_glow_alpha = glow.modulate.a if glow else 1.0
	_pulse_alpha = pulse_ring.modulate.a if pulse_ring else 1.0
	if burst:
		burst.emitting=false
	_apply_theme()
	open()

## 打开：先播一遍“从光点长成整扇门”的动画，播完切回待机循环
func open()->void:
	set_emitting(true)
	if ! body or ! body.sprite_frames or ! body.sprite_frames.has_animation("open"):
		return
	body.play("open")
	await body.animation_finished
	if ! is_leaving:
		body.play("idle")

## 进入：门收缩、光环炸成冲击波、粒子一次性爆发。
## 播完之后门就停在收起来的样子，剩下的（切场景）交给子类
func play_enter()->void:
	if is_leaving:
		return
	is_leaving=true
	if body:
		body.play("close")
	if pulse_ring:
		pulse_ring.visible=false
	#冲击波：光环猛地放大并淡出
	if aura_ring:
		var ring_tween := create_tween().set_parallel()
		ring_tween.tween_property(aura_ring,"scale",_aura_base*enter_ring_scale,enter_time*0.7).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		ring_tween.tween_property(aura_ring,"modulate:a",0.0,enter_time*0.7)
	#门自己亮一下再消失
	if glow:
		var glow_tween := create_tween()
		glow_tween.tween_property(glow,"modulate:a",1.0,enter_time*0.2)
		glow_tween.tween_property(glow,"modulate:a",0.0,enter_time*0.8)
	#已经飞出去的粒子留着，新的不再发射
	if burst:
		burst.restart()
	await get_tree().create_timer(enter_time*0.35).timeout
	set_emitting(false)

## 关门：播完收缩动画后把整扇门藏起来（想让传送门暂时不可用时调用）
func close()->void:
	set_emitting(false)
	if ! body or ! body.sprite_frames or ! body.sprite_frames.has_animation("close"):
		return
	body.play("close")
	await body.animation_finished
	visible=false

## 有角色靠近 / 离开时调用，门会“醒来”或重新安静下去
func set_wake(value:bool)->void:
	var target:=1.0 if value else 0.0
	if _wake_tween:
		_wake_tween.kill()
	_wake_tween=create_tween()
	_wake_tween.tween_property(self,"wake",target,wake_time).set_ease(Tween.EASE_OUT)

## 所有待机粒子开 / 关
func set_emitting(value:bool)->void:
	for node in _particle_nodes():
		node.emitting=value

## 把主题色乘到所有"发光"的部分上：光晕、光环、冲击波、待机粒子、爆发粒子。
## 门主体那张贴图颜色很深，染色意义不大，就保持原样（所有门共用同一条深蓝门框）。
func _apply_theme()->void:
	if theme_color != Color.WHITE and body:
		#门主体是深蓝的贴图，直接乘颜色只会变黑，所以用一个只转色相的小 shader
		var mat := ShaderMaterial.new()
		mat.shader = load("res://resource/shader/portal_hue.gdshader")
		mat.set_shader_parameter("hue_shift", theme_color.h - 0.58)   # 0.58 ≈ 原贴图的蓝色色相
		mat.set_shader_parameter("brightness", 2.2)                    # 底图很暗，提亮一点才看得出颜色
		mat.set_shader_parameter("saturation", 1.8)
		body.material = mat
	if theme_color != Color.WHITE:
		#直接用主题色替换 RGB（保留各自的 alpha），比相乘更容易拉开色差：
		#这些贴图本身是浅蓝色，乘深色只会越来越暗，替换才能得到干净的绿/紫/金。
		var tint := theme_color
		for node in [glow, aura_ring, pulse_ring, burst]:
			if node:
				node.modulate = Color(tint.r, tint.g, tint.b, node.modulate.a)
		for node in _particle_nodes():
			node.modulate = Color(tint.r, tint.g, tint.b, node.modulate.a)
	if portal_name != "":
		var label:Label = get_node_or_null("PortalName") as Label
		if label:
			label.text = portal_name
			label.visible = true
			label.modulate = theme_color.lightened(0.1)

func _particle_nodes()->Array[GPUParticles2D]:
	var list:Array[GPUParticles2D]=[]
	if effects:
		for child in effects.get_children():
			if child is GPUParticles2D:
				list.append(child)
	return list

func _process(delta:float) -> void:
	if is_leaving:
		return
	_time+=delta
	#用一个正弦波做呼吸，取值 -1 ~ 1
	var breath := sin(_time*TAU/max(breath_time,0.01))
	var zoom := 1.0+breath*breath_scale+wake*wake_scale
	if body:
		body.scale=_body_base*zoom
	if glow:
		glow.scale=_glow_base*(zoom+wake*0.4)
		glow.modulate.a=clamp(_glow_alpha+breath*breath_glow+wake*wake_glow,0.0,1.0)
	if aura_ring:
		aura_ring.rotation+=deg_to_rad(aura_speed*(1.0+wake))*delta
		aura_ring.scale=_aura_base*(1.0+breath*0.05+wake*0.18)
	#冲击波每隔 pulse_time 秒往外扩一圈：越往外的圈越淡
	if pulse_ring:
		_pulse_t=fmod(_pulse_t+delta,max(pulse_time,0.1))
		var k:float = _pulse_t/max(pulse_time,0.1)
		pulse_ring.scale=_pulse_base*(0.7+k*2.0)
		pulse_ring.modulate.a=_pulse_alpha*(1.0-k)
