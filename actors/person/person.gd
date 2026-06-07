extends Node3D

@export var character: Character

func _ready() -> void:
	var head_material: StandardMaterial3D = preload("uid://br5vxykep0o1f").duplicate()
	head_material.albedo_texture = character.portrait
	%Head.set_surface_override_material(0, head_material)


func _process(_delta: float) -> void:
	var camera := get_viewport().get_camera_3d()
	var distance: float = global_position.distance_to(camera.global_position)
	%Model.scale = Vector3.ONE * clamp(distance * .02, 1, 3)
