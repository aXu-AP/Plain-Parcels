extends Node

# Many signals are emitted externally.
@warning_ignore_start("unused_signal")
signal flag_added(StringName)
signal quest_started(Quest)
signal quest_ended(Quest)
signal jewel_collected(StringName)
signal shop_opened(ShopGui)
signal shop_closed

var flags: Array[StringName] = []
var jewels: int = 99
var coins: int = 1000
var quest_coins: int = 0
var shop_tier: int = 0
var carrier_level: int = 0


func reset_state() -> void:
	flags.clear()
	jewels = 0
	coins = 0
	shop_tier = 0
	carrier_level = 0


func add_flag(flag: StringName) -> void:
	match flag:
		&"Shop Upgrade":
			shop_tier = flags.count(flag) + 1
		&"Carrier":
			carrier_level = flags.count(flag) + 1
		_: # Don't allow multiples of other flags.
			if flag in flags:
				return
	flags.append(flag)
	flag_added.emit(flag)


func collect_jewel(jewel: StringName) -> void:
	jewels += 1
	jewel_collected.emit(jewel)
