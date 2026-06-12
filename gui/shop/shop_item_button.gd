class_name ShopItemButton
extends Control

@export var item: ShopItemData
var disabled := false
var tween: Tween

func _ready() -> void:
	if item.flag == &"":
		item.flag = StringName(item.display_name)
	if item.flag in Globals.flags:
		queue_free()
	if item.jewel_currency:
		%CurrencyTextureRect.texture = preload("res://gui/icons/jewel.png")
		%CurrencyTextureRect.modulate = Color.WHITE
	%NameLabel.text = item.display_name.replace('\\n', '\n')
	%PriceLabel.text = str(item.price)
	%IconTextureRect.texture = item.item_icon
	update_availability()
	Globals.flag_added.connect(update_availability.unbind(1))


func _gui_input(event: InputEvent) -> void:
	var mouse_event := event as InputEventMouseButton
	if mouse_event:
		if mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.pressed:
			buy()
			accept_event()
	elif event.is_action_pressed("ui_accept"):
		buy()
		accept_event()


func update_availability() -> bool:
	if item.jewel_currency:
		disabled = Globals.jewels < item.price
	else:
		disabled = Globals.coins < item.price
	modulate = Color.DARK_GRAY if disabled else Color.WHITE
	visible = Globals.shop_tier >= item.tier
	return visible and not disabled


func buy() -> void:
	if not update_availability():
		return
	if item.jewel_currency:
		Globals.jewels -= item.price
	else:
		Globals.coins -= item.price
	if item.flag == &"Fix Plane":
		Player.instance.fix()
	else:
		Globals.add_flag(item.flag)
		Globals.add_flag(item.extra_flag)
	queue_free()


func _on_focus_entered() -> void:
	if is_instance_valid(tween):
		tween.kill()
	tween = create_tween()
	tween.tween_property(self, "self_modulate", Color.WHITE, .05)


func _on_focus_exited() -> void:
	if is_instance_valid(tween):
		tween.kill()
	tween = create_tween()
	tween.tween_property(self, "self_modulate", Color.TRANSPARENT, .3)
