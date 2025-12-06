extends CharacterBody2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var player: CharacterBody2D = $"../player"
@onready var timer: Timer = $Timer



var MAX_SPEED := 100

func _ready():
	timer.timeout.connect(_on_timer_timeout)   # ① 计时器结束要回调
	animated_sprite_2d.animation_finished.connect(_on_anim_done)
	

func _physics_process(delta: float) -> void:
	var direction = get_player_position()
	velocity = direction * MAX_SPEED

	var d = global_position.distance_to(player.global_position)
	if direction.x>0:
		animated_sprite_2d.flip_h=true
	if direction.x<0:
		animated_sprite_2d.flip_h=false

	# 动画切换
	if d > 200:
		animated_sprite_2d.play("run")
	else:
		animated_sprite_2d.play("kind1")
		
		

	move_and_slide()

func get_player_position():
	return (player.global_position - global_position).normalized()

func _on_anim_done():
	if animated_sprite_2d.animation == "kind1":
		MAX_SPEED = 0          # ② 开始硬直
		timer.start(1.0)       # 2 秒

func _on_timer_timeout():
	MAX_SPEED = 100
				# ③ 计时器走完恢复速度

	
	
	
	
