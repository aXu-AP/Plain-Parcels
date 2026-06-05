extends Camera3D

@export var target: Player
@export var distance: float = 7.0
@export var height: float = 8.0
@export var max_height: float = 12.0

var snap_to_target := true
var camera_input_smoothed := Vector2.ZERO

func _ready() -> void:
	target.respawned.connect(set.bind("snap_to_target", true))

func _physics_process(delta: float) -> void:
	var target_flat: Vector3 = target.global_position - target.global_basis.z * 5
	target_flat.y = global_position.y - 3
	camera_input_smoothed = camera_input_smoothed.move_toward(Input.get_vector("camera_left", "camera_right", "camera_down", "camera_up"), delta * 10)
	var target_position := Vector3.BACK
	target_position = target_position.rotated(Vector3.RIGHT, PI / 2 * camera_input_smoothed.y)
	target_position = target_position.rotated(Vector3.UP, target.rotation.y + PI / 2 * camera_input_smoothed.x)
	var _distance = distance
	_distance -= target.is_braking * 3
	target_position = target.global_position + target_position * _distance
	var snap_amount: float = 0.04
	if snap_to_target:
		snap_amount = 1.0
		snap_to_target = false
	global_position = global_position.lerp(target_position, snap_amount)
	var height_force: float = max(0, remap(global_position.y, target.current_max_height_soft, target.current_max_height + 2, 0, 1))
	global_position.y = lerp(global_position.y, target.current_max_height_soft, height_force)
	look_at(target_flat)
	fov = lerp(fov, 80 + target.is_boosting * 10, delta * 2)
	#rotation.x += PI / 4 * camera_input_smoothed.y
