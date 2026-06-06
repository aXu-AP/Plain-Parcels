class_name ParcelQuest
extends Quest


func start_quest(source: Node3D) -> bool:
	if not super(source):
		return false
	for i in goals:
		var box = preload("uid://7l20j2o7xj5i").instantiate()
		box.quest = self
		source.get_parent().add_child(box)
		box.global_position = source.global_position
	return true


func try_goal(source: Node3D) -> EndState:
	Box.collect(source.global_position)
	return super(source)
