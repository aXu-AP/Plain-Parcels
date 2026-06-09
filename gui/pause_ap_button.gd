extends Button

func _ready() -> void:
	Archipelago.connected.connect(set.bind("visible", true).unbind(2))
	Archipelago.disconnected.connect(set.bind("visible", false))
	pressed.connect(Archipelago.open_console)
