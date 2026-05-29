extends Camera3D

@export var target: Player
@export var distance: float = 7.0
@export var height: float = 8.0
@export var max_height: float = 12.0

var snap_to_target := true

func _ready() -> void:
	target.respawned.connect(set.bind("snap_to_target", true))

func _physics_process(delta: float) -> void:
	var target_flat: Vector3 = target.global_position - target.global_basis.z * 5
	target_flat.y = global_position.y - 3
	var target_position = target.global_position + Vector3.BACK.rotated(Vector3.UP, target.rotation.y) * distance
	var snap_amount: float = 0.04
	if snap_to_target:
		snap_amount = 1.0
		snap_to_target = false
	global_position = global_position.lerp(target_position, snap_amount)
	var height_force: float = max(0.01, remap(global_position.y, height, max_height, 0, 1))
	global_position.y = lerp(global_position.y, height, height_force)
	look_at(target_flat)
