class_name HasturOperationGDPluginSettings


static func register_settings() -> void:
	if not ProjectSettings.has_setting("hastur_operation/output_max_char_length"):
		ProjectSettings.set_setting("hastur_operation/output_max_char_length", 800)
	ProjectSettings.set_initial_value("hastur_operation/output_max_char_length", 800)
	ProjectSettings.add_property_info({
		"name": "hastur_operation/output_max_char_length",
		"type": TYPE_INT,
		"hint": PROPERTY_HINT_RANGE,
		"hint_string": "100,10000,1"
	})

	if not ProjectSettings.has_setting("hastur_operation/broker_host"):
		ProjectSettings.set_setting("hastur_operation/broker_host", "localhost")
	ProjectSettings.set_initial_value("hastur_operation/broker_host", "localhost")
	ProjectSettings.add_property_info({
		"name": "hastur_operation/broker_host",
		"type": TYPE_STRING,
	})

	if not ProjectSettings.has_setting("hastur_operation/broker_port"):
		ProjectSettings.set_setting("hastur_operation/broker_port", 5301)
	ProjectSettings.set_initial_value("hastur_operation/broker_port", 5301)
	ProjectSettings.add_property_info({
		"name": "hastur_operation/broker_port",
		"type": TYPE_INT,
		"hint": PROPERTY_HINT_RANGE,
		"hint_string": "1,65535,1"
	})


static func get_output_max_char_length() -> int:
	return ProjectSettings.get_setting("hastur_operation/output_max_char_length", 800)


static func get_broker_host() -> String:
	return ProjectSettings.get_setting("hastur_operation/broker_host", "localhost")


static func get_broker_port() -> int:
	return ProjectSettings.get_setting("hastur_operation/broker_port", 5301)
