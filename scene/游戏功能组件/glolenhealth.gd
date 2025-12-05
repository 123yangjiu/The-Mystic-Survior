extends Node
@onready var animated_sprite_2d: AnimatedSprite2D = get_parent().get_node("AnimatedSprite2D")
#所有角色都可以公用这个组件，可以非常方便的计算伤害和调整数值
@onready var animation_player: AnimationPlayer = $"../AnimationPlayer"

var damage_decline:=1.0
signal died
signal health_change
@export var max_health:float=10
var current_health
func _ready() -> void:
	current_health=max_health
func on_ability_upgrade_add(upgrade:AbilityUpgrade,current_upgrade:Dictionary):
	if upgrade.ID=="盔甲":
		damage_decline-=current_upgrade["盔甲"]["quantity"]*18
func damage(damage:float):
	current_health=max(current_health-damage*damage_decline,0)
	health_change.emit()
	flash_white()#打闪
	if current_health==0:
		died.emit()
		owner.queue_free()
func get_health_persent():
	if current_health<=0:
		return 0
	return min(current_health/max_health,1)

	
func flash_white(duration := 0.12):
	if animation_player.is_playing() and animation_player.current_animation == "Flash":
		return
	animation_player.play("flash")
	
