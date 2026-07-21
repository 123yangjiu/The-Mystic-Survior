extends Node


var _broker_client: BrokerClient


func _ready() -> void:
	if not OS.is_debug_build():
		queue_free()
		return

	var broker_host = HasturOperationGDPluginSettings.get_broker_host()
	var broker_port = HasturOperationGDPluginSettings.get_broker_port()
	_broker_client = BrokerClient.new(broker_host, broker_port, "game")


func _process(delta: float) -> void:
	if _broker_client:
		_broker_client.poll(delta)


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_PREDELETE:
		if _broker_client:
			_broker_client.disconnect_client()
			_broker_client = null
