class_name QuestPoint
extends Area3D

## Quest that starts when touching this quest point.
@export var quest_to_start: Quest
## Quest that this quest point belongs to.
## If not empty, the quest point will be disabled until the quest has started.
@export var quest_to_goal: Quest


func _ready() -> void:
	if quest_to_start != null:
		quest_to_start.ended.connect(on_quest_to_start_ended)
	if quest_to_goal != null:
		quest_to_goal.started.connect(on_quest_started)
		quest_to_goal.ended.connect(on_quest_to_goal_ended)
		if quest_to_goal.status != Quest.Status.ACTIVE:
			visible = false


func on_quest_started() -> void:
	visible = true


func on_quest_to_start_ended(finished: bool) -> void:
	if !finished:
		visible = true


func on_quest_to_goal_ended(finished: bool) -> void:
	visible = false


func interact() -> void:
	if not visible:
		return
	if quest_to_goal != null:
		quest_to_goal.goals_left -= 1
		if quest_to_goal.goals_left == 0:
			QuestManager.end_quest(quest_to_goal, QuestManager.EndState.COMPLETE)
			print("Quest finished: %s!" % quest_to_goal.name)
	if quest_to_start != null:
		QuestManager.start_quest(quest_to_start)
		print("Quest started: %s!" % quest_to_start.name)
	visible = false
