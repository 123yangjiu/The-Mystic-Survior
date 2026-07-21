@tool
extends EditorPlugin


var _dock: EditorDock
var _backend: ExecutorBackend


func _enable_plugin() -> void:
	pass


func _disable_plugin() -> void:
	pass


func _enter_tree() -> void:
	HasturOperationGDPluginSettings.register_settings()

	_backend = ExecutorBackend.new()
	add_child(_backend)
	_backend.initialize(self)

	_dock = EditorDock.new()
	_dock.title = "Hastur Executor"
	_dock.default_slot = EditorDock.DOCK_SLOT_RIGHT_UL
	_dock.available_layouts = EditorDock.DOCK_LAYOUT_VERTICAL | EditorDock.DOCK_LAYOUT_FLOATING
	var dock_content = preload("executor_dock.gd").new()
	dock_content.initialize(_backend)
	_dock.add_child(dock_content)
	add_dock(_dock)


func _exit_tree() -> void:
	if _dock:
		remove_dock(_dock)
		_dock.queue_free()
		_dock = null
	if _backend:
		remove_child(_backend)
		_backend.queue_free()
		_backend = null
