extends MeshInstance3D

func _process(_delta: float) -> void:
	var camera_pos = get_viewport().get_camera_3d().global_position
	global_position = Vector3(camera_pos.x, global_position.y, camera_pos.z)
