class_name GDScriptExecutor


var _error_capturer: _CompileErrorCapturer


func _init() -> void:
	_error_capturer = _CompileErrorCapturer.new()
	OS.add_logger(_error_capturer)


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		OS.remove_logger(_error_capturer)
		_error_capturer = null


func execute_code(code: String, execute_context: Dictionary = {}, editor_plugin = null) -> Dictionary:
	var result = {
		"compile_success": false,
		"compile_error": "",
		"run_success": false,
		"run_error": "",
		"outputs": []
	}

	if code.strip_edges() == "":
		result.compile_error = "Code is empty"
		return result

	var is_full_class = _is_full_class(code)

	var source: String
	if is_full_class:
		source = _ensure_tool_annotation(code)
	else:
		source = _wrap_snippet(code)

	var script = GDScript.new()
	script.source_code = source
	var script_path = script.resource_path

	_error_capturer.start_capture(script_path)
	var compile_err = script.reload()
	var captured_errors = _error_capturer.stop_capture()

	if compile_err != OK:
		if captured_errors.size() > 0:
			result.compile_error = "\n".join(captured_errors)
		else:
			result.compile_error = _error_code_to_string(compile_err)
		script = null
		return result

	result.compile_success = true

	if not script.can_instantiate():
		result.compile_error = "Script compiled but cannot be instantiated"
		result.compile_success = false
		script = null
		return result

	_error_capturer.start_capture(script_path)
	var instance = script.new()
	captured_errors = _error_capturer.stop_capture()
	script = null

	if instance == null:
		if captured_errors.size() > 0:
			result.run_error = "\n".join(captured_errors)
		else:
			result.run_error = "Failed to instantiate script"
		return result

	var ctx = ExecutionContext.new(editor_plugin)

	_error_capturer.start_capture(script_path)
	if is_full_class:
		_execute_full_class(instance, ctx, result)
	else:
		_execute_snippet(instance, ctx, result)
	captured_errors = _error_capturer.stop_capture()

	result.outputs = ctx.get_outputs()

	if captured_errors.size() > 0:
		result.run_success = false
		result.run_error = "\n".join(captured_errors)

	instance = null
	return result


func _is_full_class(code: String) -> bool:
	return "extends" in code


func _wrap_snippet(code: String) -> String:
	var lines = code.split("\n")
	var indented = ""
	for line in lines:
		indented += "\t" + line + "\n"

	return "@tool\nextends RefCounted\n\nvar executeContext\n\nfunc run():\n" + indented


func _ensure_tool_annotation(code: String) -> String:
	if code.strip_edges().begins_with("@tool"):
		return code
	return "@tool\n" + code


func _execute_snippet(instance: RefCounted, execute_context: ExecutionContext, result: Dictionary) -> void:
	instance.executeContext = execute_context
	instance.run()
	result.run_success = true


func _execute_full_class(instance: RefCounted, execute_context: ExecutionContext, result: Dictionary) -> void:
	if not instance.has_method("execute"):
		result.run_error = "Full class mode requires an 'execute(executeContext)' method"
		return
	instance.execute(execute_context)
	result.run_success = true


func _error_code_to_string(error_code: int) -> String:
	match error_code:
		ERR_PARSE_ERROR:
			return "Parse error in script"
		ERR_COMPILATION_FAILED:
			return "Script compilation failed"
		ERR_SCRIPT_FAILED:
			return "Script execution failed"
		_:
			return "Compile error (code: %d)" % error_code


class _CompileErrorCapturer extends Logger:
	var _capturing: bool = false
	var _filter_path: String = ""
	var _captured: PackedStringArray = PackedStringArray()
	var _mutex: Mutex = Mutex.new()

	func start_capture(script_path: String) -> void:
		_mutex.lock()
		_captured.clear()
		_filter_path = script_path
		_capturing = true
		_mutex.unlock()

	func stop_capture() -> PackedStringArray:
		_mutex.lock()
		_capturing = false
		_filter_path = ""
		var result = _captured.duplicate()
		_captured.clear()
		_mutex.unlock()
		return result

	func _log_error(function: String, file: String, line: int, code: String, rationale: String, editor_notify: bool, error_type: int, script_backtraces: Array) -> void:
		_mutex.lock()
		if _capturing and error_type == Logger.ERROR_TYPE_SCRIPT and file.begins_with(_filter_path):
			var msg = rationale if rationale != "" else code
			if msg != "":
				_captured.append(msg)
		_mutex.unlock()

	func _log_message(message: String, error: bool) -> void:
		pass
