extends Camera3D

@export var target: Node3D
@export var distance: float = 8.0

func _physics_process(delta: float) -> void:
	var target_flat: Vector3 = target.global_position - target.global_basis.z * 5
	target_flat.y = global_position.y
	look_at(target_flat)
	var target_position = target.global_position + Vector3.BACK.rotated(Vector3.UP, target.rotation.y) * distance
	global_position = global_position.lerp(target_position, .05)
	global_position.y = lerp(global_position.y, 5.0, .2)
