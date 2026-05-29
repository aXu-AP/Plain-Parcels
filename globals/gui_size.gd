extends Node

func _ready() -> void:
	var ui_size = DisplayServer.screen_get_dpi() / 72.0
	var theme = ThemeDB.get_default_theme()
	theme.set_default_base_scale(ui_size * 2)
	theme.set_default_font_size(ui_size * 22)
