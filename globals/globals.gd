extends Node

signal flag_added(StringName)

var flags: Array[StringName] = []
var coins: int = 0

func reset_state() -> void:
	coins = 0

func add_flag(flag: StringName) -> void:
	if not flag in flags:
		flags.append(flag)
		flag_added.emit(flag)
