extends Node3D

@export var max_distance: float = 1000.0
@export var player: Node3D
var target_pos := Vector3.ZERO
var target_scale := Vector3.ZERO
@onready var max_distance_squared: float = max_distance * max_distance

func _process(delta: float) -> void:
	var points = get_tree().get_nodes_in_group(Groups.QUEST_POINTS)
	var closest_distance: float = max_distance_squared
	var closest_point: QuestPoint = null
	for p: QuestPoint in points:
		var distance = player.global_position.distance_squared_to(p.global_position)
		if (p.action == Quest.Action.GOAL # Is a goal point.
				and p.quest.status == Quest.Status.ACTIVE 
				and p.visible # Multigoal quest can be active even if some are collected.
				and distance < closest_distance):
			closest_distance = distance
			closest_point = p
	if is_instance_valid(closest_point):
		if target_scale == Vector3.ZERO:
			target_pos = closest_point.global_position
		target_pos = lerp(target_pos, closest_point.global_position, min(1, 10.0 * delta))
		target_scale = Vector3.ONE * clamp(remap(closest_distance, max_distance_squared / 5, max_distance_squared, 1, 0), 0, 1)
	else:
		target_scale = Vector3.ZERO
	look_at(target_pos)
	scale = lerp(scale, target_scale, min(1, 15.0 * delta))
