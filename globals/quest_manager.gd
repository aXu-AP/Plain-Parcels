extends Node

signal quest_started(quest_name: String)
signal quest_ended(quest_name: String, finished: bool)


var active_quests: Array[String] = []


func start_quest(quest: Quest) -> bool:
	if quest.status != Quest.Status.AVAILABLE:
		return false
	
	quest.status = Quest.Status.ACTIVE
	quest.goals_left = quest.goals
	quest.started.emit()
	quest_started.emit(quest)
	if quest.time_limit > 0:
		get_tree().create_timer(quest.time_limit, false).timeout.connect(end_quest.bind(quest, false))
	return true


func end_quest(quest: Quest, finished: bool) -> bool:
	if quest.status != Quest.Status.ACTIVE:
		return false
	if finished:
		quest.status = Quest.Status.COMPLETED
	else:
		quest.status = Quest.Status.AVAILABLE
	quest.ended.emit(finished)
	quest_ended.emit(quest, finished)
	return true
