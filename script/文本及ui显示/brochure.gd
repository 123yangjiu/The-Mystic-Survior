extends CanvasLayer
@onready var next: Button = $Next
@onready var pre: Button = $Pre
@onready var exit: Button = $Exit

@export var current:Node2D

@export var all:Array[Node2D]

## Called when the node enters the scene tree for the first time.

func _on_nect_button_down() -> void:
	var current_index =all.find(current)
	var new_index =current_index +1
	if new_index>=all.size():
		new_index=new_index-all.size()
	current.visible =false
	current = all.get(new_index)
	current.visible=true
	check_index(new_index)

func _on_pre_button_down() -> void:
	var current_index =all.find(current)
	var new_index =current_index -1
	if new_index<=-1:
		new_index=new_index+all.size()
	current.visible =false
	current = all.get(new_index)
	current.visible=true
	check_index(new_index)

func check_index(new_index:int)->void:
	if new_index <all.size()-1:
		next.visible=true
	else :
		exit.visible=true
		next.visible=false
	if new_index >0:
		pre.visible=true
	else :
		pre.visible=false


func _on_button_button_down() -> void:
	queue_free()
	pass # Replace with function body.
