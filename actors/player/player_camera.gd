extends Camera3D

@export var target: Player
@export var distance: float = 7.0
@export var height: float = 8.0
@export var max_height: float = 12.0

func _physics_process(delta: float) -> void:
	var target_flat: Vector3 = target.global_position - target.global_basis.z * 5
	target_flat.y = global_position.y - 3
	look_at(target_flat)
	var target_position = target.global_position + Vector3.BACK.rotated(Vector3.UP, target.rotation.y) * distance
	global_position = global_position.lerp(target_position, .04)
	var height_force: float = max(0.01, remap(global_position.y, height, max_height, 0, 1))
	global_position.y = lerp(global_position.y, height, height_force)
