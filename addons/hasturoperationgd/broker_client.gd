class_name BrokerClient
extends RefCounted


signal connection_established(id: String)
signal connection_lost()
signal remote_execution_completed(code: String, result: Dictionary, duration_ms: int)

var _tcp: StreamPeerTCP
var _host: String
var _port: int
var _connected: bool = false
var _executor_id: String = ""
var _reconnect_delay: float = 1.0
var _max_reconnect_delay: float = 30.0
var _reconnect_timer: float = 0.0
var _buffer: String = ""
var _executor: GDScriptExecutor
var _project_name: String
var _project_path: String
var _editor_pid: int
var _plugin_version: String
var _editor_version: String
var _executor_type: String = "editor"


var _editor_plugin_ref = null


func _init(host: String, port: int, executor_type: String = "editor", editor_plugin = null) -> void:
	_host = host
	_port = port
	_executor_type = executor_type
	_editor_plugin_ref = editor_plugin
	_tcp = StreamPeerTCP.new()
	_executor = GDScriptExecutor.new()
	_project_name = ProjectSettings.get_setting("application/config/name", "Unnamed")
	_project_path = ProjectSettings.globalize_path("res://")
	_editor_pid = OS.get_process_id()
	_plugin_version = "0.1"
	var version_info = Engine.get_version_info()
	_editor_version = str(version_info.get("major", 0)) + "." + str(version_info.get("minor", 0)) + "." + str(version_info.get("patch", 0))
	_try_connect()


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE and _tcp != null:
		if _tcp:
			_tcp.disconnect_from_host()
		_connected = false
		_executor_id = ""
		_buffer = ""
		_executor = null


func disconnect_client() -> void:
	if _tcp:
		_tcp.disconnect_from_host()
	_connected = false
	_executor_id = ""
	_buffer = ""


func poll(delta: float) -> void:
	_tcp.poll()
	var status = _tcp.get_status()

	match status:
		StreamPeerTCP.STATUS_NONE:
			if _connected:
				_handle_disconnect()
			_reconnect_timer += delta
			if _reconnect_timer >= _reconnect_delay:
				_reconnect_timer = 0.0
				_try_connect()
		StreamPeerTCP.STATUS_CONNECTING:
			pass
		StreamPeerTCP.STATUS_CONNECTED:
			if not _connected:
				_connected = true
				_reconnect_delay = 1.0
				_reconnect_timer = 0.0
				_send_register()
			_read_data()
		StreamPeerTCP.STATUS_ERROR:
			if _connected:
				_handle_disconnect()
			_reconnect_timer += delta
			if _reconnect_timer >= _reconnect_delay:
				_reconnect_timer = 0.0
				_reconnect_delay = min(_reconnect_delay * 2.0, _max_reconnect_delay)
				_try_connect()


func get_executor_id() -> String:
	return _executor_id


func is_broker_connected() -> bool:
	return _connected


func _try_connect() -> void:
	var status = _tcp.get_status()
	if status != StreamPeerTCP.STATUS_NONE and status != StreamPeerTCP.STATUS_ERROR:
		push_warning("BrokerClient: _try_connect called in unexpected status %d, skipping connect_to_host" % status)
		return
	if status != StreamPeerTCP.STATUS_NONE:
		_tcp.disconnect_from_host()
	_tcp.connect_to_host(_host, _port)


func _handle_disconnect() -> void:
	push_warning("BrokerClient: connection lost to %s:%d (executor_id=%s)" % [_host, _port, _executor_id])
	_connected = false
	_executor_id = ""
	_buffer = ""
	_reconnect_delay = 1.0
	connection_lost.emit()


func _send_register() -> void:
	var msg = {
		"type": "register",
		"data": {
			"project_name": _project_name,
			"project_path": _project_path,
			"editor_pid": _editor_pid,
			"plugin_version": _plugin_version,
			"editor_version": _editor_version,
			"supported_languages": ["gdscript"],
			"type": _executor_type
		}
	}
	_send_message(msg)


func _read_data() -> void:
	while _tcp.get_available_bytes() > 0:
		var result = _tcp.get_partial_data(_tcp.get_available_bytes())
		if result[0] == OK:
			var data: PackedByteArray = result[1]
			_buffer += data.get_string_from_utf8()

	if "\n" not in _buffer:
		return

	var parts = _buffer.split("\n")
	_buffer = parts[-1]
	for i in range(parts.size() - 1):
		var line = parts[i].strip_edges()
		if line != "":
			_handle_message(line)


func _handle_message(raw: String) -> void:
	var json = JSON.new()
	var err = json.parse(raw)
	if err != OK:
		return

	var msg = json.data
	if not msg is Dictionary:
		return

	var type = msg.get("type", "")
	var data = msg.get("data", {})

	match type:
		"register_result":
			_handle_register_result(data)
		"execute":
			_handle_execute(data)
		"ping":
			_send_message({"type": "pong"})


func _handle_register_result(data: Dictionary) -> void:
	if data.get("success", false):
		_executor_id = str(data.get("id", ""))
		connection_established.emit(_executor_id)
	else:
		push_warning("BrokerClient: registration rejected by broker: %s" % str(data))
		_tcp.disconnect_from_host()
		_connected = false


func _handle_execute(data: Dictionary) -> void:
	var request_id = str(data.get("request_id", ""))
	var code = str(data.get("code", ""))
	var start_time = Time.get_ticks_msec()
	var result = _executor.execute_code(code, {}, _editor_plugin_ref)
	var end_time = Time.get_ticks_msec()
	var duration_ms = end_time - start_time
	var msg = {
		"type": "execute_result",
		"data": {
			"request_id": request_id,
			"compile_success": result.get("compile_success", false),
			"compile_error": result.get("compile_error", ""),
			"run_success": result.get("run_success", false),
			"run_error": result.get("run_error", ""),
			"outputs": result.get("outputs", [])
		}
	}
	_send_message(msg)
	remote_execution_completed.emit(code, result, duration_ms)


func _send_message(msg: Dictionary) -> void:
	if _tcp.get_status() != StreamPeerTCP.STATUS_CONNECTED:
		push_warning("BrokerClient: _send_message called while not connected (status=%d), dropping message: %s" % [_tcp.get_status(), msg.get("type", "unknown")])
		return
	var json_str = JSON.stringify(msg) + "\n"
	var err = _tcp.put_data(json_str.to_utf8_buffer())
	if err != OK:
		push_warning("BrokerClient: put_data failed with error %d for message type: %s" % [err, msg.get("type", "unknown")])
