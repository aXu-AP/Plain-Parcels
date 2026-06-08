extends Node3D

@export var quest: Quest


func _ready() -> void:
	quest.started.connect(spawn_coins)
	quest.ended.connect(despawn_coins.unbind(1))
	despawn_coins()


func spawn_coins() -> void:
	var tween = create_tween()
	for child: Node in get_children():
		if "appear" in child:
			tween.tween_callback(child.appear)
			tween.tween_interval(.1)


func despawn_coins() -> void:
	for child: Node in get_children():
		if "disappear" in child:
			child.disappear()
