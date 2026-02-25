extends AgainstThing
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
func _ready() -> void:
	animated_sprite_2d.animation_finished.connect(on_finish)

func _physics_process(_delta: float) -> void:
	self.global_position=GameEvent.play_global_position

func on_finish():
	queue_free()
