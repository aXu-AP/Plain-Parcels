extends Area3D


func _process(delta: float) -> void:
	rotation.y += TAU * delta


func _on_area_entered(_area: Area3D) -> void:
	Player.instance.health = Player.instance.max_health
	$MeshInstance3D.visible = false
	$CollectParticles.emitting = true
	set_deferred("monitoring", false)
	get_tree().create_timer(10, false).timeout.connect(appear)


func appear() -> void:
	set_deferred("monitoring", true)
	$MeshInstance3D.visible = true
	set_process(true)


func disappear() -> void:
	set_deferred("monitoring", false)
	$MeshInstance3D.visible = false
	set_process(false)
