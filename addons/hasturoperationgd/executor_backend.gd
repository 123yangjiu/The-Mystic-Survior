@tool
class_name ExecutorBackend
extends Node


signal connection_state_changed(connected: bool, executor_id: String)
signal execution_completed(entry: Dictionary)
signal history_cleared()


var _executor: GDScriptExecutor
var _broker_client: BrokerClient
var _editor_plugin = null
var _history: Array = []
var _max_history: int = 50


func initialize(p_editor_plugin) -> void:
	_editor_plugin = p_editor_plugin


func _ready() -> void:
	_executor = GDScriptExecutor.new()
	var broker_host = HasturOperationGDPluginSettings.get_broker_host()
	var broker_port = HasturOperationGDPluginSettings.get_broker_port()
	_broker_client = BrokerClient.new(broker_host, broker_port, "editor", _editor_plugin)
	_broker_client.connection_established.connect(_on_broker_connected)
	_broker_client.connection_lost.connect(_on_broker_disconnected)
	_broker_client.remote_execution_completed.connect(_on_remote_execution)


func _process(delta: float) -> void:
	if _broker_client:
		_broker_client.poll(delta)


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		if _broker_client:
			_broker_client.disconnect_client()
			_broker_client = null
		_executor = null


func execute_code(code: String) -> Dictionary:
	var start_time = Time.get_ticks_msec()
	var result = _executor.execute_code(code, {}, _editor_plugin)
	var end_time = Time.get_ticks_msec()
	var duration_ms = end_time - start_time
	var entry = {
		"code": code,
		"result": result,
		"timestamp": Time.get_time_string_from_system(),
		"duration_ms": duration_ms,
		"source": "local"
	}
	_add_to_history(entry)
	execution_completed.emit(entry)
	return result


func get_history() -> Array:
	return _history


func clear_history() -> void:
	_history.clear()
	history_cleared.emit()


func _on_broker_connected(id: String) -> void:
	connection_state_changed.emit(true, id)


func _on_broker_disconnected() -> void:
	connection_state_changed.emit(false, "")


func _on_remote_execution(code: String, result: Dictionary, duration_ms: int) -> void:
	var entry = {
		"code": code,
		"result": result,
		"timestamp": Time.get_time_string_from_system(),
		"duration_ms": duration_ms,
		"source": "remote"
	}
	_add_to_history(entry)
	execution_completed.emit(entry)


func _add_to_history(entry: Dictionary) -> void:
	_history.append(entry)
	if _history.size() > _max_history:
		_history.pop_front()
