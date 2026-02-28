class_name Rocket
extends FlyThing
@onready var attack_component_2: AttackComponent = $AttackComponent2
var collision_shape_2d: CollisionShape2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AttackComponent2/AnimatedSprite2D
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D

var dir_enemy_global_position:Vector2
var expolotion_damage :=50

func _ready() -> void:
	amount=100
	attack_component.area_2d.area_entered.connect(on_area_enter)
	timer.timeout.connect(on_timer_out)
	collision_shape_2d = attack_component_2.collision_shape_2d

func _physics_process(_delta: float) -> void:
	global_position+=direction*speed
	var gap=(self.global_position-dir_enemy_global_position).length_squared()
	if gap<1000 and speed!=0:
		speed=0
		expolation()

func expolation()->void:
	animated_sprite_2d.visible=true
	animated_sprite_2d.global_rotation=0
	animated_sprite_2d.play("explotion")
	audio_stream_player_2d.play()
	await animated_sprite_2d.frame_changed
	sprite_2d.visible=false
	collision_shape_2d.disabled = false
	await animated_sprite_2d.animation_finished
	queue_free()
