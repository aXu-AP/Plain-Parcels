extends Area3D

@export_file("*.tscn") var level: String
@export var entrance_name: String


func _ready() -> void:
	body_entered.connect(enter.unbind(1))


func enter() -> void:
	GameManager.load_level(level)
