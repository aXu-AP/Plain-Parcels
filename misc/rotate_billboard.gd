extends Sprite3D


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func _process(_delta: float) -> void:
	rotation = Vector3.ZERO
	var camera_pos_g: Vector3 = get_viewport().get_camera_3d().global_position
	var camera_pos_l: Vector3 = to_local(camera_pos_g)
	var camera_dir: Vector2 = Vector2(camera_pos_l.x, camera_pos_l.z).normalized()
	frame = roundi(camera_dir.angle() / (PI / 2) + 5) % 4
	look_at(camera_pos_g, global_basis.y, true)
