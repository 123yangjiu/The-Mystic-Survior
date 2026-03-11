class_name AchievementCard
extends Control

@export var id:AchievementManager.AchievementID

@onready var icon_rect: TextureRect = $HBoxContainer/PanelContainer/Icon
@onready var name_label: Label = $HBoxContainer/VBoxContainer/NameLabel
@onready var describe_label: Label = $HBoxContainer/VBoxContainer/DescribeLabel


func _ready() -> void:
	if AchievementManager.achievements_data.has(id):
		var achievement = AchievementManager.achievements_data[id]
		if achievement["got"]:
			on_achievement_unlocked()

func on_achievement_unlocked()->void:
	icon_rect.modulate = Color(1.0, 1.0, 1.0, 1.0)
