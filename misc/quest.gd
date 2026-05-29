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

@export var name: String
@export var goals: int = 1
@export var time_limit: int = 0
@export_group("Multipart", "multi_part")
@export var continuation: Quest
@export var status := Status.AVAILABLE
@export var start_message: Message
@export var goal_message: Message
@export var fail_message: Message
@export var mid_goal_messages: Array[Message]

var goals_left: int
