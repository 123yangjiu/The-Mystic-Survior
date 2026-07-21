extends StatusEffect
class_name ConfusionEffect

var _mapping: Dictionary = {}
var _saved_events: Dictionary = {}

func _ready():
	_generate_mapping()
	_apply_keyboard_mapping()
	process_physics_priority = -1

func _generate_mapping():
	var actions := ["left", "right", "up", "down"]
	var shuffled := actions.duplicate()
	shuffled.shuffle()
	for i in 4:
		_mapping[actions[i]] = shuffled[i]

func _apply_keyboard_mapping():
	for action in ["left", "right", "up", "down"]:
		_saved_events[action] = InputMap.action_get_events(action)
		InputMap.action_erase_events(action)
	for original in _mapping:
		var mapped = _mapping[original]
		for event in _saved_events[original]:
			InputMap.action_add_event(mapped, event)

func _restore_keyboard_mapping():
	for action in ["left", "right", "up", "down"]:
		InputMap.action_erase_events(action)
	for action in _saved_events:
		for event in _saved_events[action]:
			InputMap.action_add_event(action, event)
	_saved_events.clear()

func _exit_tree():
	if not _saved_events.is_empty():
		_restore_keyboard_mapping()

func _physics_process(_delta):
	var player = get_parent()
	if not player or not player.is_touch:
		return
	if player.direction.length() < 0.01:
		return
	player.direction = _confuse_direction(player.direction)

func _confuse_direction(dir: Vector2) -> Vector2:
	var cardinals := {
		"right": Vector2.RIGHT,
		"left": Vector2.LEFT,
		"down": Vector2.DOWN,
		"up": Vector2.UP
	}
	var best = "right"
	var best_dot = -INF
	for name in cardinals:
		var d = dir.dot(cardinals[name])
		if d > best_dot:
			best_dot = d
			best = name
	return cardinals[_mapping[best]]
