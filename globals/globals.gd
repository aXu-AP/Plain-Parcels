extends Node

signal flag_added(StringName)
signal quest_started(Quest)
signal quest_ended(Quest)

var flags: Array[StringName] = []
var coins: int = 0
var quest_coins: int = 0


func reset_state() -> void:
	flags.clear()
	coins = 0


func add_flag(flag: StringName) -> void:
	if not flag in flags:
		flags.append(flag)
		flag_added.emit(flag)
