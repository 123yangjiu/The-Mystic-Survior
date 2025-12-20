extends CanvasLayer

var can_free :=false

func _ready() -> void:
	get_tree().paused = true
	await get_tree().create_timer(0.3).timeout
	can_free=true
	

func _process(_delta: float) -> void:
	if can_free:
		if Input.is_action_pressed("暂停"):
			get_tree().paused=false
			queue_free()
