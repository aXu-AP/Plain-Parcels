extends Node3D

@export var text: String

func _ready() -> void:
	$Label3D.text = text
