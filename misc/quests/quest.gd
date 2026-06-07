class_name Quest
extends Resource

signal started
signal ended(end_state: EndState)
signal status_changed(new_status: Status)

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
	FAIL_TRIGGER,
	ABANDON,
	CONTINUE,
	CUSTOM1,
	CUSTOM2,
	CUSTOM3,
}

enum Action {
	START,
	GOAL,
	FAIL,
	CUSTOM1,
	CUSTOM2,
	CUSTOM3,
}

static var active_quest: Quest

@export var name: StringName
@export var goals: int = 1
@export var time_limit: int = 0
@export var status := Status.AVAILABLE:
	get():
		return status
	set(val):
		status = val
		status_changed.emit(status)
@export var start_message: Message
@export var end_messages: Dictionary[EndState, Message]
@export var mid_goal_messages: Array[Message]
## Delays setting active_quest to null after finishing this quest.
## Use this if the goal overlaps with another quest.
@export var delay_finishing := true
@export var show_arrow := true


var goals_left: int
var timer: SceneTreeTimer


## Responds to given action.
## Override to react to custom actions.
func do_action(source: Node3D, action: Action) -> void:
	match action:
		Action.START: start_quest(source)
		Action.GOAL: end_quest(try_goal(source))
		Action.FAIL: end_quest(EndState.FAIL_TRIGGER)


## Marks a subgoal completed and checks if the quest can be completed.
## Can be overridden for custom condition checking.
func try_goal(_source: Node3D) -> EndState:
	goals_left -= 1
	if goals_left <= 0:
		return EndState.COMPLETE
	var msg_id = goals - goals_left - 1
	if mid_goal_messages.size() > msg_id and mid_goal_messages[msg_id]:
		DialogueBox.queue_message(mid_goal_messages[msg_id])
	return EndState.CONTINUE


## Starts the quest. If another quest is ongoing, abandon it.
func start_quest(_source: Node3D) -> bool:
	if status != Status.AVAILABLE:
		return false
	
	if active_quest:
		active_quest.end_quest(EndState.ABANDON)
	
	print("%s started" % name)
	status = Quest.Status.ACTIVE
	goals_left = goals
	if start_message:
		DialogueBox.queue_message(start_message)
	if time_limit > 0:
		timer = Player.instance.get_tree().create_timer(time_limit, false)
		timer.timeout.connect(end_quest.bind(EndState.TIMEOUT))
	started.emit()
	active_quest = self
	Globals.quest_started.emit(self)
	return true


## Ends the quest unless state is CONTINUE. Displays a corresponding message from end_messages.
func end_quest(state: EndState) -> bool:
	if status != Quest.Status.ACTIVE or state == EndState.CONTINUE:
		return false
	if is_instance_valid(timer) and timer.timeout.is_connected(end_quest.bind(EndState.TIMEOUT)):
		timer.timeout.disconnect(end_quest.bind(EndState.TIMEOUT))
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
	if delay_finishing:
		await Globals.get_tree().create_timer(3).timeout
	active_quest = null
	Globals.quest_ended.emit(self)
	return true
