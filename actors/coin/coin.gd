extends Area3D


func enable() -> void:
	set_deferred("monitoring", true)
	$MeshInstance3D.visible = true


func _process(delta: float) -> void:
	rotation.y += TAU * delta


func _on_area_entered(area: Area3D) -> void:
	$MeshInstance3D.visible = false
	$CollectParticles.emitting = true
	set_deferred("monitoring", false)
