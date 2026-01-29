extends Button

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var kunnan: Label = $Kunnan
@onready var putong: Label = $Putong

func _ready() -> void:
	if GameEvent.is_hard:
		to_hard(0.0)
		animated_sprite_2d.frame=8
	else :
		to_easy(0.0)
		animated_sprite_2d.frame=0


func _on_button_up() -> void:
	if ! GameEvent.is_hard:
		to_hard()
	else :
		to_easy()

func to_hard(time=0.3)->void:
	GameEvent.is_hard=true
	var tween = create_tween().set_parallel().set_ease(Tween.EASE_IN_OUT)
	animated_sprite_2d.play("default")
	tween.tween_property(putong,"modulate",Color(0.0, 0.0, 0.0, 1.0),time)
	tween.tween_property(kunnan,"modulate",Color(1.0, 1.0, 1.0, 1.0),time)


func to_easy(time=0.3)->void:
	GameEvent.is_hard=false
	var tween = create_tween().set_parallel().set_ease(Tween.EASE_IN_OUT)
	animated_sprite_2d.play_backwards("default")
	tween.tween_property(putong,"modulate",Color(1.0, 1.0, 1.0, 1.0),time)
	tween.tween_property(kunnan,"modulate",Color(0.0, 0.0, 0.0, 1.0),time)
