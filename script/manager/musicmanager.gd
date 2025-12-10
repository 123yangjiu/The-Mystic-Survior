class_name MusicManager
extends Node
@onready var maintheme: AudioStreamPlayer = $Maintheme
@onready var the_first: AudioStreamPlayer = $TheFirst
@onready var w_ith_wolf: AudioStreamPlayer = $WIthWolf
@onready var w_ith_gorlen: AudioStreamPlayer = $WIthGorlen
@onready var the_final: AudioStreamPlayer = $TheFinal



func _ready() -> void:
	GameEvent.more_difficulty.connect(on_more_difficulty)
	GameEvent.the_first_damage.connect(on_the_first_damage)

func on_more_difficulty(difficulty := 0)->void:
	match difficulty:
		6:
			w_ith_wolf.play()
		11:
			await w_ith_wolf.finished
			w_ith_gorlen.play()
			

func on_the_first_damage()->void:
	the_first.play()


func _on_w_ith_gorlen_finished() -> void:
	await get_tree().create_timer(1).timeout
	the_final.play()
	pass # Replace with function body.
