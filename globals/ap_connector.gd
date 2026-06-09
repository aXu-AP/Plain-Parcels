class_name APConnector
extends Node

static var instance: APConnector

var JEWEL := Item.new(1000, "Jewel")
var CARRIER := Item.new(1001, "Progressive Carrier")
var BOOST := Item.new(1002, "Boost")
var BRAKE := Item.new(1003, "Brake")
var RETRACT := Item.new(1004, "Wing Retract")
var PASSENGER := Item.new(1005, "Passenger Seat")
var COIN_1 := Item.new(2000, "Coin", true)
var COIN_10 := Item.new(2001, "10 Coins", true)
var COIN_20 := Item.new(2002, "20 Coins", true)
var DAMAGE_TRAP := Item.new(3000, "Damage Trap", true)

var BEACH_COINS := Location.new(1000, "Beach Coins")
var BIRD_FEEDING_1 := Location.new(1001, "Bird Feeding 1")
var BIRD_FEEDING_2 := Location.new(1002, "Bird Feeding 2")
var COOKIE_DELIVERY := Location.new(1003, "Cookie Delivery")
var MAKING_FRIENDS := Location.new(1004, "Making Friends")
var SHADY_BUSINESS := Location.new(1005, "Shady Business", &"Shady Business 2")
var STATUE_CLEANING := Location.new(1006, "Statue Cleaning")
var CRANE_JEWEL := Location.new(2000, "Crane Jewel")
var FOUNTAIN_JEWEL := Location.new(2001, "Fountain Jewel")
var RICH_MAN_GATE_JEWEL := Location.new(2002, "Rich Man Gate Jewel")

var outgoing_locations: Array[int] = []
var first_items := true


static func create() -> APConnector:
	if not is_instance_valid(instance):
		instance = APConnector.new()
	return instance


func _ready() -> void:
	Globals.reset_state()
	Archipelago.connected.connect(_on_ap_connected)
	Globals.flag_added.connect(send_location)
	Globals.jewel_collected.connect(_on_jewel_collected)
	GameManager.game_ended.connect(queue_free)


func _exit_tree() -> void:
	Archipelago.ap_disconnect()
	Globals.reset_state()


func _on_ap_connected(conn: ConnectionInfo, _json: Dictionary) -> void:
	conn.obtained_item.connect(receive_item)
	# A bit of a hack to check if the items are on first batch or not.
	# obtained_items get emitted after all items are separately emitted via obtained_item.
	conn.obtained_items.connect(set.bind("first_items", false).unbind(1), ConnectFlags.CONNECT_ONE_SHOT)
	for id: int in conn.slot_locations:
		if conn.slot_locations[id]:
			Globals.add_flag(Location.by_id[id].flag)


func _on_jewel_collected(jewel: StringName) -> void:
	if jewel != &"AP":
		Globals.jewels -= 1 # Undo vanilla jewels.


func send_location(flag: StringName) -> void:
	var loc: Location = Location.by_flag.get(flag, null)
	if loc:
		outgoing_locations.append(loc.id)
		try_send_locations()


func try_send_locations() -> void:
	if not Archipelago.is_ap_connected():
		return
	Archipelago.collect_locations(outgoing_locations)
	outgoing_locations.clear()


func receive_item(ap_item: NetworkItem):
	print("Status %s" % Archipelago.status)
	var item: Item = Item.by_id.get(ap_item.id)
	if not item:
		return
	if first_items and item.temporary:
		return
	var sender: String = Archipelago.conn.get_player_name(ap_item.src_player_id)
	var msg := Message.new()
	msg.text = "%s found your %s" % [sender, item.name]
	DialogueBox.queue_message(msg)
	match item.flag:
		JEWEL.flag:
			Globals.collect_jewel(&"AP")
		COIN_1.flag:
			Globals.coins += 1
		COIN_10.flag:
			Globals.coins += 10
		COIN_20.flag:
			Globals.coins += 20
		DAMAGE_TRAP.flag:
			Player.instance.do_damage(10)
		_:
			Globals.add_flag(item.flag)


class Location:
	var id: int
	var name: String
	var flag: StringName
	
	static var by_id: Dictionary[int, Location] = {}
	static var by_flag: Dictionary[StringName, Location] = {}
	
	func _init(_id: int, _name: String, _flag: StringName = &"") -> void:
		id = _id
		name = _name
		if _flag != &"":
			flag = _flag
		else:
			flag = StringName(_name)
		by_id[id] = self
		by_flag[flag] = self


class Item:
	var id: int
	var name: String
	var temporary : bool
	var flag: StringName
	
	static var by_id: Dictionary[int, Item] = {}
	
	func _init(_id: int, _name: String, _temporary := false, _flag: StringName = &"") -> void:
		id = _id
		name = _name
		temporary = _temporary
		if _flag != &"":
			flag = _flag
		else:
			flag = StringName(_name)
		by_id[id] = self
