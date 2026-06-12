class_name ShopItemData
extends Resource

@export var display_name: String
## Unique flag that marks if this item has been bought.
## Empty for same as display_name.
@export var flag: StringName = &""
## Another flag that gets added when item is bought.
@export var extra_flag: StringName = &""
@export var price: int
@export var item_icon: Texture2D
@export var tier: int
@export var jewel_currency: bool
