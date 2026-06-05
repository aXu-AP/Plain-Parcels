class_name Quest
extends Resource

signal started
signal ended(finished: bool)

enum Status {
	LOCKED,
	AVAILABLE,
	ACTIVE,
	COMPLETED,
}

enum EndState {
	COMPLETE,
	TIMEOUT,
	BROKEN,
	CRASH,
	ABANDON,
	CUSTOM1,
	CUSTOM2,
	CUSTOM3,
}

static var active_quest: Quest

@export var name: String
@export var goals: int = 1
@export var time_limit: int = 0
@export var start_message: Message
@export var status := Status.AVAILABLE
@export var end_messages: Dictionary[EndState, Message]
@export var mid_goal_messages: Array[Message]
@export var attach_boxes := true
@export var continuation: Quest

var goals_left: int


func start_quest() -> bool:
	if status != Status.AVAILABLE:
		return false
	
	if active_quest:
		active_quest.end_quest(EndState.ABANDON)
	
	print("%s started" % name)
	status = Quest.Status.ACTIVE
	active_quest = self
	goals_left = goals
	started.emit()
	if start_message:
		DialogueBox.queue_message(start_message)
	if time_limit > 0:
		var timer = Player.instance.get_tree().create_timer(time_limit, false)
		timer.timeout.connect(end_quest.bind(EndState.TIMEOUT))
		Gui.connect_timer(timer)
	return true


func end_quest(state: EndState) -> bool:
	if status != Quest.Status.ACTIVE:
		return false
	print("%s ended with %s" % [name, state])
	if state == EndState.COMPLETE:
		status = Status.COMPLETED
		Globals.add_flag(name)
	else:
		status = Status.AVAILABLE
	var message = end_messages.get(state)
	if message:
		DialogueBox.queue_message(message)
	ended.emit(state)
	active_quest = null
	return true
