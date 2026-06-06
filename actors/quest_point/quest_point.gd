class_name QuestPoint
extends Area3D

signal quest_started
signal quest_ended(end_state: Quest.EndState)

## What to do with the quest. Possible values: [code]start[/code], [code]goal[/code] or custom-defined ones.
@export var action: Quest.Action
## Set of flags that are required for this questpoint to show up.
## Additionally the visibility is controlled by quest status.
@export var required_flags: Array[StringName] = []
## How many seconds to wait after required flags are available until the questpoint will show up.
@export var availability_delay: int = 0
## Quest that the action gets sent on interact.
@export var quest: Quest


func _ready() -> void:
	update_visibility()
	quest.status_changed.connect(update_visibility.unbind(1))
	Globals.flag_added.connect(update_visibility.bind(availability_delay).unbind(1))
	quest.started.connect(quest_started.emit)
	quest.ended.connect(quest_ended.emit)


func update_visibility(delay: int = 0) -> void:
	if delay:
		await get_tree().create_timer(delay).finished
	# The quest is completed, quest no longer available.
	if quest.name in required_flags:
		queue_free()
	visible = check_visibility()
	set_deferred("monitoring", visible)


func check_visibility() -> bool:
	if not required_flags.all(func (f): return f in Globals.flags):
		return false
	if action == Quest.Action.START and quest.status != Quest.Status.AVAILABLE:
		return false
	if action != Quest.Action.START and quest.status != Quest.Status.ACTIVE:
		return false
	return true


func interact() -> void:
	if not visible:
		return
	quest.do_action(self, action)
	visible = false
	set_deferred("monitoring", false)
	var anim := get_node_or_null("AnimationPlayer") as AnimationPlayer
	if anim and anim.has_animation(&"cutscene"):
		anim.process_mode = Node.PROCESS_MODE_ALWAYS
		anim.play(&"cutscene", 1)
		get_tree().paused = true
		anim.animation_finished.connect(get_tree().set.bind("paused", false).unbind(1))
