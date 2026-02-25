class_name AllGunAbilityController
extends Node2D


@export var all_gun:Array[PackedScene]
var damage_range:=1.0
var number_range:=1.0
var wait_range:=1.0

#这个节点只负责切换子节点
func _ready() -> void:
	GameEvent.ability_upgrade_add.connect(on_ability_upgrade_add)

func on_ability_upgrade_add(upgrade:AbilityUpgrade,_current_upgrade:Dictionary):
	if upgrade.ID=="枪的伤害":
		damage_range*=1.3
	if upgrade.ID=="枪的弹夹":
		number_range *=1.2
		wait_range -=0.1
	if upgrade.ID=="":
		pass
	var gun_index :=-1
	if upgrade.ID=="解锁枪":
		gun_index=0
	elif upgrade.ID =="解锁霰弹枪":
		gun_index=1
	elif upgrade.ID =="解锁狙击枪":
		gun_index=2
	elif upgrade.ID =="解锁RPG":
		gun_index=3
	if gun_index >=0:
		for i in get_children():
			i.zidan_number.queue_free()
			i.queue_free()
		var gun = all_gun[gun_index].instantiate() as AK47AbilityController
		add_child(gun)
		gun.damage_range=damage_range
		gun.number_range=number_range
		gun.wait_range=wait_range
		self.position=gun.init_position
