extends Area3D

@export_file("*.tscn") var level: String
@export var entrance_name: String


func _ready() -> void:
	body_entered.connect(enter.unbind(1))


func enter() -> void:
	var scene = load(level).instantiate()
	get_tree().change_scene_to_node.call_deferred(scene)
