extends Node

signal paused
signal unpaused
signal level_changed
signal transition_started
signal transition_ended
signal game_started
signal game_ended

@export_file("*.tscn") var game_path := "res://game.tscn"
@export_file("*.tscn") var main_menu_path := "res://gui/main_menu.tscn"
@export_file("*.tscn") var pause_menu_path := "res://gui/pause_menu.tscn"
@export_file("*.tscn") var transition_path := "res://gui/scene_transitions/fade_transition.tscn"

var ui_layer: CanvasLayer
var pause_menu: Node
var transition: AnimationPlayer

var in_game := false
var prevent_pause := false


func _enter_tree() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	ui_layer = CanvasLayer.new()
	ui_layer.layer = 1000
	
	pause_menu = load(pause_menu_path).instantiate()
	pause_menu.visible = false
	ui_layer.add_child(pause_menu)
	
	transition = load(transition_path).instantiate()
	
	call_deferred("add_child", ui_layer)


func start_game() -> void:
	load_level(game_path)
	await level_changed
	in_game = true
	game_started.emit()
	resume()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and in_game and not prevent_pause:
		if not get_tree().paused:
			pause()
		else:
			resume()
		get_viewport().set_input_as_handled()


func open_main_menu() -> void:
	in_game = false
	game_ended.emit()
	load_level(main_menu_path)
	await level_changed # Don't resume until current level is unloaded
	resume()


func pause() -> void:
	get_tree().paused = true
	pause_menu.visible = true
	_grab_focus_first(pause_menu)
	emit_signal("paused")


func _grab_focus_first(target : Node) -> bool:
	if "focus_mode" in target and target.focus_mode == Control.FOCUS_ALL:
		target.grab_focus()
		return true
	else:
		var success := false
		for child in target.get_children():
			success = _grab_focus_first(child)
			if success:
				break
		return success


func resume() -> void:
	get_tree().paused = false
	pause_menu.visible = false
	emit_signal("unpaused")


func load_level(path : String):
	transition_started.emit()
	if transition:
		ui_layer.add_child(transition)
		transition.play("fade_out")
		await transition.animation_finished
	
	get_tree().change_scene_to_file(path)
	await get_tree().process_frame
	
	level_changed.emit()
	
	if transition:
		transition.play("fade_in")
		await transition.animation_finished
		ui_layer.remove_child(transition)
	transition_ended.emit()


func quit() -> void:
	if transition:
		ui_layer.add_child(transition)
		transition.play("fade_out")
		await transition.animation_finished
	in_game = false
	game_ended.emit()
	get_tree().quit()
