extends CharacterBody2D
class_name Player

@onready var wound_component: WoundComponent = $WoundComponent
@onready var health_component: HealthComponent = $health_component

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var health_bar: ProgressBar = $HealthBar

@onready var all_gun_ability_controller: AllGunAbilityController = $abilitymanager/AllGunAbilityController
@onready var light_ability_controller: Node2D = $abilitymanager/light_ability_controller

@export var died_screen:PackedScene

var direction:=Vector2(0,0)
var vec:Vector2
var is_run:=false:set=set_is_run
#手机移动
var is_touch:=false
func _ready() -> void:
    #添加分组
    add_to_group("player")
    #初始化血量为满血
    health_bar.value=health_component.get_health_persent()

    GameEvent.blood_bottle_collected.connect(on_blood_bottle_collected)
    GameEvent.ability_upgrade_add.connect(on_ability_upgrade_add)
    health_component.health_change.connect(on_health_change)
    health_component.died.connect(on_died)

    
@export var MAX_speed=120
func _physics_process(_delta: float) -> void:
    GameEvent.play_global_position=global_position
    if !is_touch:
        direction=get_move_direction().normalized()
    velocity=direction*MAX_speed
    if direction.length() != 0.0:
        is_run=true
    else:
        is_run=false
    move_and_slide()
    if direction.x<0:
        animated_sprite_2d.offset.x=0.0
        animated_sprite_2d.flip_h=false
        GameEvent.play_right=false
    if direction.x>0:
        animated_sprite_2d.offset.x=-4.0
        animated_sprite_2d.flip_h=true
        light_ability_controller.scale.x=1
        GameEvent.play_right=true

func set_is_run(value)->void:
    if is_run!= value:
        match value:
            true:
                animated_sprite_2d.play()
            false:
                animated_sprite_2d.stop()
    is_run=value
func get_move_direction():
    var movement_x=Input.get_action_strength("right")-Input.get_action_strength("left")
    var movement_y=Input.get_action_strength("down")-Input.get_action_strength("up")
    return Vector2(movement_x,movement_y)


func on_health_change():
    health_bar.value=health_component.get_health_persent()


func on_died()->void:
    GameEvent.player_died.emit()
    var screen=died_screen.instantiate()
    get_viewport().add_child(screen)


func on_blood_bottle_collected(blood:int):
    health_component.current_health=min(health_component.max_health,health_component.current_health+blood)
    on_health_change()

func on_ability_upgrade_add(upgrade:AbilityUpgrade,_current_upgrade:Dictionary):
    if upgrade.ID=="盔甲":
        var percent = wound_component.current_wound_degree*0.08
        wound_component.wound_degree -=percent
        health_component.max_health*=1.1
        health_component.current_health*=1.1
    if upgrade.ID=="飞毛腿":
        MAX_speed*=1.15
