extends AudioStreamPlayer3D

var area: CollisionPolygon3D
var target_pos: Vector3

func _ready() -> void:
	area = get_parent()
	var timer := Timer.new()
	add_child(timer)
	timer.timeout.connect(calc_position)
	timer.wait_time = .2
	get_tree().create_timer(randf() * .2).timeout.connect(timer.start)


func _process(delta: float) -> void:
	global_position = global_position.lerp(target_pos, delta * 2)


func calc_position() -> void:
	var listener: Camera3D = get_viewport().get_camera_3d()
	var local_pos: Vector3 = area.to_local(listener.global_position)
	var pos_2d := Vector2(local_pos.x, local_pos.y)
	if not Geometry2D.is_point_in_polygon(pos_2d, area.polygon):
		var min_distance: float = INF
		var closest_pos: Vector2 = pos_2d
		for i in range(area.polygon.size()):
			var new_pos: Vector2 = Geometry2D.get_closest_point_to_segment(pos_2d, area.polygon[i], area.polygon[(i + 1) % area.polygon.size()])
			var distance = new_pos.distance_squared_to(pos_2d)
			if distance < min_distance:
				closest_pos = new_pos
				min_distance = distance
		pos_2d = closest_pos
	target_pos = area.to_global(Vector3(pos_2d.x, pos_2d.y, clampf(local_pos.z, -area.depth, 0)))
