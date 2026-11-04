extends Node

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	await get_tree().create_timer(1.5).timeout
	var map: Node = get_tree().current_scene
	var player := get_tree().get_first_node_in_group("player")
	print("T|scene=", map.name, " player=", player)
	if player:
		print("T|player groups=", player.get_groups())
	var term: Node2D = (load("res://scene/场景互动件/图鉴终端.tscn") as PackedScene).instantiate()
	map.add_child(term)
	term.global_position = player.global_position + Vector2(40, 0)
	await get_tree().create_timer(0.3).timeout
	term._inside = true
	var ev := InputEventAction.new()
	ev.action = "ui_accept"
	ev.pressed = true
	term._unhandled_input(ev)
	await w(0.4)
	var codex: Node = term._codex
	print("T|codex=", codex, " paused=", get_tree().paused)
	if codex:
		codex._show_mode("skill")
		await w(0.4)
		var names := []
		for e in codex.entries:
			names.append(e.name)
		print("T|skill entries=", codex.entries.size(), " : ", " ".join(names))
		_shot("skill")
	await w(0.2)
	get_tree().quit()

func w(t: float) -> void:
	await get_tree().create_timer(t, true).timeout

func _shot(name: String) -> void:
	var img := get_viewport().get_texture().get_image()
	img.convert(Image.FORMAT_RGBA8)
	if img.get_width() != 640:
		img.resize(640, 360, Image.INTERPOLATE_NEAREST)
	img.save_png("res://dsh_p/" + name + ".png")
