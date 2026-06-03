extends Area3D

func _process(delta: float) -> void:
	rotation.y += TAU * delta


func _on_area_entered(area: Area3D) -> void:
	$MeshInstance3D.visible = false
	$CollectParticles.emitting = true
	$CollectParticles.finished.connect(queue_free)
