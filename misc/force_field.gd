class_name ForceField
extends Area3D

@export var local_direction := Vector3.UP
var global_direction: Vector3
var plane: Plane


func _ready() -> void:
	recalculate_plane()


func recalculate_plane() -> void:
	global_direction = global_basis * local_direction
	plane = Plane(global_direction, global_position)
