class_name ConfirmStuff
extends Node2D

@export var collision_area:Area2D

@export var check_area:Area2D

@export var interval_timer:Timer

var is_player_entered:=false
var is_timer_ready:=true

func _ready() -> void:
	if check_area:
		check_area.body_entered.connect(_on_check_body_entered)
	if interval_timer:
		interval_timer.timeout.connect(_on_interval_timer_timeout)

func _on_check_body_entered(body:Node2D)->void:
	if ! body is Player:
		return
	is_player_entered =true

func _input(event: InputEvent) -> void:
	if ! is_player_entered or ! is_timer_ready:
		return
	if ! event.is_action_pressed("confirm"):
		return
	input_event()
	if interval_timer:
		is_timer_ready = false
		interval_timer.start()

func input_event()->void:
	pass

func _on_interval_timer_timeout()->void:
	is_timer_ready=true
