extends Node

signal flag_added(StringName)
signal quest_started(Quest)
signal quest_ended(Quest)
signal jewel_collected(StringName)

var flags: Array[StringName] = []
var jewels: int = 0
var coins: int = 0
var quest_coins: int = 0


func reset_state() -> void:
	flags.clear()
	jewels = 0
	coins = 0


func add_flag(flag: StringName) -> void:
	if not flag in flags:
		flags.append(flag)
		flag_added.emit(flag)


func collect_jewel(jewel: StringName) -> void:
	jewels += 1
	jewel_collected.emit(jewel)
