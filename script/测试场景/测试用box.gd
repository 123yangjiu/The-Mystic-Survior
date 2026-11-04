class_name Sandbag
extends Enemy

## 测试用沙包：头顶显示「近 20 秒内最高的一次伤害」和「DPS」，每挨一下播放一次 hurt 动画。
##
## 不改 WoundComponent / HealthComponent：伤害从 health_component 的血量差值里算，
## 所以这套逻辑只在这个测试场景里生效，不影响其它敌人。

const WINDOW := 20.0          #统计窗口（秒）
const REFRESH := 0.1          #标签刷新间隔（秒），别每帧改 Label

@onready var label: Label = $Label

var _hits: Array[Vector2] = []   # x = 这一次的伤害，y = 发生时间（秒）
var _last_health := 0.0
var _refresh_timer := 0.0

func _ready() -> void:
	super()
	_last_health = health_component.current_health
	health_component.health_change.connect(_on_health_change)
	_update_label()

func _process(delta: float) -> void:
	_refresh_timer += delta
	if _refresh_timer < REFRESH:
		return
	_refresh_timer = 0.0
	_prune(_now())
	_update_label()

#---- 记录伤害 ----
func _on_health_change() -> void:
	var health := health_component.current_health
	var damage: float = _last_health - health
	_last_health = health
	if damage <= 0.0:      #初始化 / 回血时差值不是正的，跳过
		return
	var now := _now()
	_hits.append(Vector2(damage, now))
	_prune(now)
	_play_hurt()
	_update_label()

## 丢掉 20 秒之前的记录
func _prune(now: float) -> void:
	while ! _hits.is_empty() and now - _hits[0].y > WINDOW:
		_hits.remove_at(0)

#---- 显示 ----
func _update_label() -> void:
	if _hits.is_empty():
		label.text = "最高 0\nDPS 0.0"
		return
	var max_hit := 0.0
	var total := 0.0
	for hit in _hits:
		max_hit = maxf(max_hit, hit.x)
		total += hit.x
	#窗口还没满 20 秒时按已经过的时长算，第一秒也不至于把 DPS 拉爆
	var span := clampf(_now() - _hits[0].y, 1.0, WINDOW)
	label.text = "最高 %d\nDPS %.1f" % [int(max_hit), total / span]

#---- 受击动画 ----
func _play_hurt() -> void:
	var sprite := animated_sprite_2d
	if sprite.sprite_frames == null or ! sprite.sprite_frames.has_animation(&"hurt"):
		return
	sprite.stop()
	sprite.set_frame_and_progress(0, 0.0)
	sprite.play(&"hurt")

func _now() -> float:
	return Time.get_ticks_msec() / 1000.0
