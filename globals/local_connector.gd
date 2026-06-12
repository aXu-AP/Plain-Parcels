class_name LocalConnector
extends Node

var ignore_updates := false
var save_file = "user://savegame.dat"

func _ready() -> void:
	Globals.flag_added.connect(update_save.unbind(1))
	GameManager.level_changed.connect(update_save)


func load_game() -> void:
	Globals.reset_state()
	SaveManager.load_game(save_file)
	var flags = SaveManager.permanent_data.get("flags", [])
	ignore_updates = true
	for flag in flags:
		Globals.add_flag(flag)
	ignore_updates = false
	SaveManager.permanent_data["flags"] = Globals.flags
	Globals.jewels = SaveManager.permanent_data.get("jewels", 0)
	Globals.coins = SaveManager.permanent_data.get("coins", 0)
	GameManager.game_path = SaveManager.permanent_data.get("level", "uid://7b2px7k842e6")


func start_new() -> void:
	Globals.reset_state()
	SaveManager.permanent_data["flags"] = Globals.flags
	SaveManager.permanent_data["jewels"] = Globals.jewels
	SaveManager.permanent_data["coins"] = Globals.coins


func update_save() -> void:
	if ignore_updates:
		return
	# Flags is by reference always up to date, other data needs to be manually updated.
	SaveManager.permanent_data["jewels"] = Globals.jewels
	SaveManager.permanent_data["coins"] = Globals.coins
	SaveManager.permanent_data["level"] = GameManager.current_level
	print(GameManager.current_level)
	SaveManager.save_game(save_file)


func quit() -> void:
	update_save()
	queue_free()
