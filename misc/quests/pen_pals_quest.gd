extends ParcelQuest

@export var checkpoint_message: Message
@export var fail_1_message: Message
@export var fail_2_message: Message
@export var broken_1_message: Message
@export var broken_2_message: Message
var checkpoint := false

func start_quest(source: Node3D) -> bool:
	if not super(source):
		return false
	checkpoint = false
	return true


func do_action(source: Node3D, action: Action) -> void:
	if action == Action.GOAL:
		DialogueBox.queue_message(checkpoint_message, true)
		Box.collect(source.global_position)
		var box = preload("uid://7l20j2o7xj5i").instantiate()
		box.quest = self
		source.get_parent().add_child(box)
		box.global_position = source.global_position
		checkpoint = true
		return
	elif not checkpoint and action == Action.CUSTOM1:
		end_quest(EndState.CUSTOM1)
	elif checkpoint and action == Action.CUSTOM1:
		end_quest(EndState.COMPLETE)
	else:
		super(source, action)


func end_quest(state: EndState) -> bool:
	if not super(state):
		return false
	match state:
		EndState.BROKEN:
			DialogueBox.queue_message(broken_2_message if checkpoint else broken_1_message, true)
		EndState.FAIL_TRIGGER:
			DialogueBox.queue_message(fail_2_message if checkpoint else fail_1_message, true)
	return true
