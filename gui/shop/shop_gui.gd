class_name ShopGui
extends Control

@export var inventory: ShopInventory
var shop_name: String

func _ready() -> void:
	GameManager.prevent_pause = true
	get_tree().paused = true
	Globals.shop_opened.emit(self)
	var first := true
	for item in inventory.items:
		var new_item: ShopItemButton = load("uid://bvup33jhbscac").instantiate()
		new_item.item = item
		%InventoryContainer.add_child(new_item)
		if first:
			new_item.grab_focus()
			first = false
	update_coins()
	Globals.flag_added.connect(update_coins.unbind(1))


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		queue_free()


func _exit_tree() -> void:
	GameManager.prevent_pause = false
	get_tree().paused = false
	get_viewport().set_input_as_handled()
	Globals.shop_closed.emit()


func update_coins() -> void:
	%CoinsLabel.text = str(Globals.coins)
	%JewelLabel.text = str(Globals.jewels)
