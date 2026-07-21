class_name ExecutionContext
extends RefCounted


var editor_plugin = null
var _outputs: Array = []
var _max_output_length: int = 800


func _init(p_editor_plugin = null) -> void:
	editor_plugin = p_editor_plugin
	_max_output_length = HasturOperationGDPluginSettings.get_output_max_char_length()


func output(key: String, value: String) -> void:
	if value.length() > _max_output_length:
		var actual_length = value.length()
		var warning = "[TRUNCATED: Output exceeded %d char limit. Refine output to be more focused. Actual length: %d] " % [_max_output_length, actual_length]
		var remaining = _max_output_length - warning.length()
		value = warning + value.substr(0, remaining)
	_outputs.append([key, value])


func get_outputs() -> Array:
	return _outputs
