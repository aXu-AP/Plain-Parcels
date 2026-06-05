extends Area3D

@export var quest_name: StringName


func _ready() -> void:
	if quest_name in Globals.flags:
		queue_free()


func _process(delta: float) -> void:
	rotation.y += TAU * delta


func _on_area_entered(area: Area3D) -> void:
	$MeshInstance3D.visible = false
	$CollectParticles.emitting = true
	$CollectParticles.finished.connect(queue_free)
	Globals.add_flag(quest_name)
