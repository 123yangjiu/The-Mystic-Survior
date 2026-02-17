extends CanvasLayer
@onready var turn_left: Button = $turn_left
@onready var turn_right: Button = $turn_right
@onready var 简单模式: Control = $简单模式

@export var all_mode:Array[Control]
@export var initial_node:Control

var current_node:Control

func _ready() -> void:
	if GameEvent.mode_index!=-1:
		initial_node.visible=false
		current_node=all_mode.get(GameEvent.mode_index)
		current_node.visible=true
		check_index(GameEvent.mode_index)
		return
	initial_node.visible=true
	current_node=initial_node
	for node in all_mode:
		if node != initial_node:
			node.visible=false
	

func _on_name_pressed() -> void:
	var current_index =all_mode.find(current_node)
	GameEvent.mode_index=current_index
	queue_free()

func _on_turn_left_pressed() -> void:
	var current_index =all_mode.find(current_node)
	var new_index =current_index -1
	if new_index<=-1:
		new_index=new_index+all_mode.size()
	current_node.visible=false
	current_node=all_mode.get(new_index)
	current_node.visible=true
	check_index(new_index)

func _on_turn_right_pressed() -> void:
	var current_index =all_mode.find(current_node)
	var new_index =current_index +1
	if new_index>=all_mode.size():
		new_index=new_index-all_mode.size()
	current_node.visible=false
	current_node=all_mode.get(new_index)
	current_node.visible=true
	check_index(new_index)

func check_index(new_index:int)->void:
	if new_index <all_mode.size()-1:
		turn_right.visible=true
	else :
		turn_right.visible=false
	if new_index >0:
		turn_left.visible=true
	else :
		turn_left.visible=false
