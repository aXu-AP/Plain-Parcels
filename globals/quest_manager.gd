extends Node

signal quest_started(quest_name: String)
signal quest_ended(quest_name: String, finished: bool)

enum EndState {
	COMPLETE,
	FAIL,
	ABANDON,
}

var active_quest: Quest

func start_quest(quest: Quest) -> bool:
	if quest.status != Quest.Status.AVAILABLE:
		return false
	
	if active_quest:
		end_quest(active_quest, EndState.ABANDON)
	
	active_quest = quest
	quest.status = Quest.Status.ACTIVE
	quest.goals_left = quest.goals
	quest.started.emit()
	quest_started.emit(quest)
	if quest.start_message:
		DialogueBox.queue_message(quest.start_message)
	if quest.time_limit > 0:
		get_tree().create_timer(quest.time_limit, false).timeout.connect(end_quest.bind(quest, EndState.FAIL))
	return true


func end_quest(quest: Quest, finished: EndState) -> bool:
	if quest.status != Quest.Status.ACTIVE:
		return false
	if finished == EndState.COMPLETE:
		quest.status = Quest.Status.COMPLETED
		if quest.goal_message:
			DialogueBox.queue_message(quest.goal_message)
	elif finished == EndState.FAIL:
		if quest.fail_message:
			DialogueBox.queue_message(quest.fail_message)
		quest.status = Quest.Status.AVAILABLE
	elif finished == EndState.ABANDON:
		quest.status = Quest.Status.AVAILABLE
	print("%s ended with %s" % [quest.name, finished])
	quest.ended.emit(finished == EndState.COMPLETE)
	quest_ended.emit(quest, finished == EndState.COMPLETE)
	active_quest = null
	return true
