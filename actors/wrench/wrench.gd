extends Area3D

@onready var wrench: Node3D = $wrench

func _process(delta: float) -> void:
	wrench.rotation.y += TAU * delta


func _on_area_entered(_area: Area3D) -> void:
	set_deferred("monitoring", false)
	remove_child(wrench)
	Player.instance.add_child(wrench)
	$FixAudio.play()
	var tween = create_tween()
	var angle = randf() * TAU
	var pos = Vector3.RIGHT.rotated(Vector3.FORWARD, angle) * 2
	tween.tween_property(wrench, "position", pos, .3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SPRING)
	angle += TAU / 4 + randf() * PI
	pos = Vector3.RIGHT.rotated(Vector3.FORWARD, angle) * 2
	tween.tween_property(wrench, "position", pos, .3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SPRING)
	angle += TAU / 4 + randf() * PI
	pos = Vector3.RIGHT.rotated(Vector3.FORWARD, angle) * 2
	tween.tween_property(wrench, "position", pos, .3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SPRING)
	tween.tween_property(wrench, "scale", Vector3.ZERO, .1).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CIRC)
	tween.tween_callback(finish_fix)


func finish_fix() -> void:
	Player.instance.fix()
	wrench.get_parent().remove_child(wrench)
	add_child(wrench)
	wrench.position = Vector3.ZERO
	wrench.scale = Vector3.ONE * 3.5
	wrench.visible = false
	$CollectParticles.global_position = Player.instance.global_position
	$CollectParticles.emitting = true
	get_tree().create_timer(10, false).timeout.connect(appear)


func appear() -> void:
	set_deferred("monitoring", true)
	wrench.visible = true
	set_process(true)


func disappear() -> void:
	set_deferred("monitoring", false)
	wrench.visible = false
	set_process(false)
