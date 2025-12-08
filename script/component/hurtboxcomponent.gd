extends Area2D
class_name HutboxComponent
@onready var animated_sprite_2d: AnimatedSprite2D = get_parent().get_node("AnimatedSprite2D")


@export var health_component:Node
var floating_text_scene=preload("res://scene/ui/floatingtext.tscn")
func _ready() -> void:
	area_entered.connect(on_area_enter)
func on_area_enter(other_area:Area2D):
	if not other_area is HitboxComponent:
		return
	var hitbox_component:=other_area as HitboxComponent
	health_component.damage(hitbox_component.damage)
	#flash_white()
	var floating_text=floating_text_scene.instantiate() as Node2D
	get_tree().get_first_node_in_group("前景图层").add_child(floating_text)
	floating_text.global_position=global_position
	floating_text.start(str(hitbox_component.damage))

#var flash_tween: Tween		  # 你的精灵
#func flash_white(duration := 0.12) -> void:
	#if flash_tween:
		#flash_tween.kill()          # 旧闪白直接掐掉
	#flash_tween = create_tween()
	#var origin = modulate
	#modulate = Color.RED
	#flash_tween.tween_property(self, "modulate", origin, duration)
#func flash_white(duration := 0.12):
	#var original = animated_sprite_2d.modulate          # 记下原来颜色
	#animated_sprite_2d.modulate = Color.WHITE*3           # 瞬间全白
	#await get_tree().create_timer(duration).timeout
	#create_tween().tween_property(animated_sprite_2d, "modulate", original, 0.08)




	
		
	
	
	
	
	
