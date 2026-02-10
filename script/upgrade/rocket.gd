class_name Rocket
extends FlyThing
@onready var hitbox_component_2: HitboxComponent = $"hitbox component2"
@onready var animated_sprite_2d: AnimatedSprite2D = $"hitbox component2/AnimatedSprite2D"
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D

#方向和速度
#var direction:=Vector2(1.0,1.0)
#var speed =5
#穿透数量和伤害
#var amount :=1
#var damage :=5.0

var dir_enemy_global_position:Vector2
var expolotion_damage :=50
func _ready() -> void:
	amount=100
	hitbox_component.area_entered.connect(on_area_enter)
	timer.timeout.connect(on_time_out)
func on_area_enter(area:Area2D):
	if area.is_in_group("enemy"):
		amount-=1
	if amount==0:
		queue_free()

func _physics_process(_delta: float) -> void:
	global_position+=direction*speed
	var gap=(self.global_position-dir_enemy_global_position).length()
	if gap<20 and speed!=0:
		speed=0
		expolation()

func on_time_out()->void:
	queue_free()

func expolation()->void:
	animated_sprite_2d.visible=true
	animated_sprite_2d.global_rotation=0
	animated_sprite_2d.play("explotion")
	audio_stream_player_2d.play()
	await animated_sprite_2d.frame_changed
	sprite_2d.visible=false
	hitbox_component_2.monitorable=true
	hitbox_component_2.monitoring=true
	await animated_sprite_2d.animation_finished
	queue_free()
