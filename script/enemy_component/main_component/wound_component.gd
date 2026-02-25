class_name WoundComponent
extends EnemyComponent

@onready var area_2d: Area2D = $Area2D
@export var collision_shape_2d: CollisionShape2D
var animated_sprite_2d: AnimatedSprite2D
var health_component:HealthComponent
var inside_area:Array[AreaInComponent] :set= set_inside_area
#受伤效果
var wound_degree:=1.0
var floating_text_scene=preload("res://scene/ui/floatingtext.tscn")
var is_flashing=false

func _ready() -> void:
	if ! owner.is_node_ready():
		await owner.ready
	about_node()
	#设置属性
	about_type()
	set_else()

func set_else()->void:
	pass

func about_node()->void:
	var _owner = owner
	health_component=_owner.health_component
	animated_sprite_2d=_owner.animated_sprite_2d
	#设置基础节点owner
	for node in get_children():
		if node == collision_shape_2d:
			var ori_global_position = collision_shape_2d.global_position
			remove_child(collision_shape_2d)
			area_2d.add_child(collision_shape_2d)
			collision_shape_2d.global_position=ori_global_position

func about_type()->void:
	area_2d.set_collision_layer_value(3,true)
	area_2d.set_collision_layer_value(2,false)
	var _owner = owner as Enemy
	_owner.all_component.append(self)

func set_inside_area(value:Array[AreaInComponent])->void:
	for area in value:
		if ! area:
			value.erase(area)
	inside_area=value

func on_be_attacked(damage:float)->void:
	match GameEvent.mode_index:
		2,3:
			damage=damage*1.1
		_:
			pass
	var new_damage = int(damage*wound_degree)+1
	wound_effect(new_damage)

func wound_effect(damage:int)->void:
	health_component.on_damage(damage)
	flash_text(damage)
	flash_white()

func flash_text(damage:int)->void:
	var floating_text=floating_text_scene.instantiate() as Node2D
	get_tree().get_first_node_in_group("前景图层").add_child(floating_text)
	floating_text.global_position=global_position
	floating_text.start(str(damage))

func flash_white(duration := 0.08):
	if is_flashing:               #正在闪就直接返回
		return
	is_flashing = true            #上锁
	var original = animated_sprite_2d.modulate
	animated_sprite_2d.modulate = Color.WHITE * 3
	await get_tree().create_timer(duration).timeout
	var tween = create_tween()
	tween.tween_property(animated_sprite_2d, "modulate", original, duration)
	await tween.finished   # 等 tween 结束
	is_flashing = false                            #解锁

func _on_area_2d_area_exited(area: Area2D) -> void:
	for in_area in inside_area:
		if area == in_area:
			inside_area.erase(inside_area)
