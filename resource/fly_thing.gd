class_name FlyThing
extends Node2D

#起始方向和速度
var direction:=Vector2(1.0,1.0)
var speed =5
#穿透数量和伤害
var amount :=1
var damage :=5.0
@export var hitbox_component:Area2D
@export var timer:Timer
