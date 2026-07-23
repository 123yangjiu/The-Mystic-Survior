class_name Portal
extends Node2D

@export var collision_shape:CollisionShape2D





func _on_area_2d_area_entered(area:Area2D) -> void:
	#检测进入的area是否是 AreaInComponent
	if ! area is AreaInComponent:
		return
	var _area = area as AreaInComponent
	#使用内置函数返回area隶属的component
	var component := _area.return_component()
	#防止自己检测自己
	if component.owner == owner:
		return
	if ! component is WoundComponent:
		return
	var _component = component as WoundComponent
	var player = _component.owner as Player
	if ! player is Player:
		return
