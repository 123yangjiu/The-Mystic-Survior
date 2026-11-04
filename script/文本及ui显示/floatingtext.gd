extends Node2D

## 受伤飘字。
## 动画播完之后不再 queue_free，而是还回 FloatingTextPool 复用（见 floating_text_pool.gd）。

var _move_tween:Tween
var _scale_tween:Tween

func start(text:String) -> void:
	$Label.text=text
	_kill_tweens()
	_move_tween=create_tween()
	_move_tween.set_parallel()
	_move_tween.tween_property(self,"global_position",global_position+(Vector2.UP*16),.3)\
	.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)

	_move_tween.chain()

	_move_tween.tween_property(self,"global_position",global_position+(Vector2.UP*48),.5)\
	.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)

	_move_tween.tween_property(self,"scale",Vector2.ONE,.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)

	_move_tween.chain()
	_move_tween.tween_callback(_on_animation_end)

	_scale_tween=create_tween()
	_scale_tween.tween_property(self,"scale",Vector2.ONE*1.5,.15).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	_scale_tween.tween_property(self,"scale",Vector2.ONE,.15).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)

## 一次动画结束：把自己还给池子（而不是销毁）
func _on_animation_end() -> void:
	FloatingTextPool.recycle(self)

func _kill_tweens() -> void:
	if _move_tween and _move_tween.is_valid():
		_move_tween.kill()
	if _scale_tween and _scale_tween.is_valid():
		_scale_tween.kill()
	_move_tween=null
	_scale_tween=null
