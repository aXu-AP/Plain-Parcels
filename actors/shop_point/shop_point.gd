extends Area3D


func interact() -> void:
	var shop_gui: ShopGui = load("uid://darjdei22adsg").instantiate()
	add_child(shop_gui)
