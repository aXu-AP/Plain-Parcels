class_name PassengerQuest
extends Quest

@export var character: Character
@export var max_health: int
var hits: int
@export var damage_messages: Array[Message]
var invincible := false

func start_quest(source: Node3D) -> bool:
	if not super(source):
		return false
	Player.instance.set_passenger(character)
	Player.instance.damaged.connect(damaged)
	hits = 0
	return true


func end_quest(state: EndState) -> bool:
	if not super(state):
		return false
	Player.instance.set_passenger(null)
	if Player.instance.damaged.is_connected(damaged):
		Player.instance.damaged.disconnect(damaged)
	return true


func damaged() -> void:
	if invincible:
		return
	if damage_messages.size() > hits:
		DialogueBox.queue_message(damage_messages[hits])
	hits += 1
	if hits >= max_health:
		end_quest(EndState.CUSTOM1)
	else:
		invincible = true
		Globals.get_tree().create_timer(3).timeout.connect(set.bind("invincible", false))
