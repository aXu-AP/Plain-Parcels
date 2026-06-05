class_name QuestPoint
extends Area3D

## Quest that starts when touching this quest point.
@export var quest_to_start: Quest
## Quest that this quest point belongs to.
## If not empty, the quest point will be disabled until the quest has started.
@export var quest_to_goal: Quest


func _ready() -> void:
	if quest_to_start != null:
		if quest_to_start.name in Globals.flags:
			queue_free()
		quest_to_start.ended.connect(on_quest_to_start_ended.unbind(1))
	if quest_to_goal != null:
		quest_to_goal.started.connect(on_quest_started)
		quest_to_goal.ended.connect(on_quest_to_goal_ended.unbind(1))
		if quest_to_goal.status != Quest.Status.ACTIVE:
			visible = false


func on_quest_started() -> void:
	visible = true


func on_quest_to_start_ended() -> void:
	visible = true


func on_quest_to_goal_ended() -> void:
	visible = false


func interact() -> void:
	if not visible:
		return
	if quest_to_goal != null:
		quest_to_goal.goals_left -= 1
		if quest_to_goal.attach_boxes:
			Box.collect(global_position)
		if quest_to_goal.goals_left == 0:
			quest_to_goal.end_quest(Quest.EndState.COMPLETE)
	if quest_to_start != null and quest_to_start.start_quest():
		if quest_to_start.attach_boxes:
			for i in quest_to_start.goals:
				var box = preload("uid://7l20j2o7xj5i").instantiate()
				box.quest = quest_to_start
				get_parent().add_child(box)
				box.global_position = global_position
	visible = false
