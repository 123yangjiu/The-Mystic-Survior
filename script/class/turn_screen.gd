class_name TurnScreen
extends CanvasLayer
@export var turn_left:Button
@export var turn_right:Button
@export var confirm:Button

@export_category("请按照顺序点")
@export var all_mode:Array[Control]
@export var initial_node:Control

var current_node:Control

func _ready() -> void:
	initial_node.visible=true
	current_node=initial_node
	for node in all_mode:
		if node != initial_node:
			node.visible=false
	if turn_left:
		turn_left.pressed.connect(_on_turn_left_pressed)
	if turn_right:
		turn_right.pressed.connect(_on_turn_right_pressed)
	if confirm:
		confirm.pressed.connect(_on_confirm_pressed)
	initial()

func initial()->void:
	pass

func _on_confirm_pressed() -> void:
	pass

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
