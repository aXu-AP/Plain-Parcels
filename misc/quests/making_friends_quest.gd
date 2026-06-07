extends PassengerQuest

@export var max_wrong_goals: int
@export var wrong_person_message: Message
var wrong_goals: int


func start_quest(source: Node3D) -> bool:
	if not super(source):
		return false
	wrong_goals = 0
	return true


func do_action(source: Node3D, action: Action) -> void:
	if action == Action.CUSTOM1:
		DialogueBox.queue_message(wrong_person_message, true)
		wrong_goals += 1
		if wrong_goals >= max_wrong_goals:
			end_quest(EndState.CUSTOM2)
	super(source, action)
