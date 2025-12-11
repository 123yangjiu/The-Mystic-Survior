class_name MusicManager
extends Node

@onready var main_theme: AudioStreamPlayer = $MainTheme
@onready var the_first: AudioStreamPlayer = $TheFirst
@onready var with_wolf: AudioStreamPlayer = $WithWolf
@onready var with_gorlen: AudioStreamPlayer = $WithGorlen
@onready var the_final: AudioStreamPlayer = $TheFinal



func _ready() -> void:
	GameEvent.more_difficulty.connect(on_more_difficulty)
	GameEvent.the_first_damage.connect(on_the_first_damage)

func on_more_difficulty(difficulty := 0)->void:
	match difficulty:
		6:
			with_wolf.play()
		11:
			if with_wolf.playing:
				await with_wolf.finished
			with_gorlen.play()
		15:
			if with_gorlen.playing:
				await with_gorlen.finished
			the_final.play()

func on_the_first_damage()->void:
	the_first.play()


func _on_w_ith_gorlen_finished() -> void:
	await get_tree().create_timer(1).timeout
	the_final.play()
	pass # Replace with function body.
