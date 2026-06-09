class_name LocalConnector
extends Node


func _ready() -> void:
	Globals.flag_added.connect(SaveManager.save_game.unbind(1))
	GameManager.level_changed.connect(update_save)


func load_game() -> void:
	SaveManager.load_game()
	Globals.flags = SaveManager.permanent_data.get("flags", [])
	Globals.jewels = SaveManager.permanent_data.get("jewels", 0)
	Globals.coins = SaveManager.permanent_data.get("coins", 0)


func start_new() -> void:
	Globals.reset_state()
	SaveManager.permanent_data["flags"] = Globals.flags
	SaveManager.permanent_data["jewels"] = Globals.jewels
	SaveManager.permanent_data["coins"] = Globals.coins


func update_save() -> void:
	# Flags is by reference always up to date, other data needs to be manually updated.
	SaveManager.permanent_data["jewels"] = Globals.jewels
	SaveManager.permanent_data["coins"] = Globals.coins
	SaveManager.save_game()


func quit() -> void:
	update_save()
	queue_free()
