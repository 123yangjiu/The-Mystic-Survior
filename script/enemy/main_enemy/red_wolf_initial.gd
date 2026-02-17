class_name CopyEnemy
extends Enemy

@export var copy_object:Array[PackedScene]
@export var number:=2
@export var angle :=PI/4
@export var distance:=30

var is_copy:=false


func copy()->void:
	var n:=0
	print("copy")
	for i in copy_object:
		var another_wolf = i.instantiate()
		get_parent().add_child(another_wolf)
		another_wolf.global_position=_get_position(n)
		n+=1

func _get_position(i:=0)->Vector2:
	var direction := (global_position-GameEvent.play_global_position).normalized()
	var ready_position:=direction*distance
	if i % 2==0:
		ready_position=ready_position.rotated(angle)
	else:
		ready_position=ready_position.rotated(-angle)
	ready_position +=global_position
	return ready_position

func _on_copy_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player") or is_copy: 
		return
	is_copy=true
	call_deferred("copy")
