extends Node

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	await get_tree().create_timer(1.5).timeout
	var codex: Node = (load("res://scene/ui/图鉴/图鉴.tscn") as PackedScene).instantiate()
	get_tree().root.add_child(codex)
	codex.open()
	await get_tree().create_timer(0.3, true).timeout
	codex._show_mode("enemy")
	await get_tree().create_timer(0.3, true).timeout
	print("T|enemies=", codex.entries.size(), " paused=", get_tree().paused)
	codex._show_mode("skill")
	await get_tree().create_timer(0.3, true).timeout
	print("T|skills=", codex.entries.size())
	codex.close()
	await get_tree().create_timer(0.3, true).timeout
	print("T|closed paused=", get_tree().paused)
	get_tree().quit()
