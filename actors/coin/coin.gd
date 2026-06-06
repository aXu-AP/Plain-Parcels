extends Area3D


@export var is_quest_coin := false


func _process(delta: float) -> void:
	rotation.y += TAU * delta


func _on_area_entered(area: Area3D) -> void:
	if is_quest_coin:
		Globals.quest_coins += 1
	else:
		Globals.coins += 1
	$MeshInstance3D.visible = false
	$CollectParticles.emitting = true
	set_deferred("monitoring", false)


func appear() -> void:
	set_deferred("monitoring", true)
	$MeshInstance3D.visible = true
	set_process(true)


func disappear() -> void:
	set_deferred("monitoring", false)
	$MeshInstance3D.visible = false
	set_process(false)
