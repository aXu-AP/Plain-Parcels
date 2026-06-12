extends Area3D

@export var shop_name: String

func interact() -> void:
	var shop_gui: ShopGui = load("uid://darjdei22adsg").instantiate()
	shop_gui.shop_name = shop_name
	add_child(shop_gui)
