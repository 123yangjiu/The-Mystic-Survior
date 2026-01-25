extends CanvasLayer
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

func _ready() -> void:
	GameEvent.paused+=1
	get_tree().paused = true
	%restart.pressed.connect(on_restart_press)
	%quit.pressed.connect(on_quit_press)
	await get_tree().create_timer(0.6).timeout
	audio_stream_player.play()


func on_restart_press():
	await get_tree().create_timer(0.1).timeout
	GameEvent.paused=0
	get_tree().paused= false
	GameEvent.difficulty=1
	GameEvent.the_first=0
	get_tree().change_scene_to_file("res://scene/game.tscn")
	GameEvent.difficulty_timer.start()
	queue_free()
	pass

func  on_quit_press():
	get_tree().quit()
	pass
