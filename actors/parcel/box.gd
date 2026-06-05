class_name Box
extends Node3D

static var box_queue: Array[Box] = []
static var hits_to_crumble = 1

var target: Node3D
var max_distance: float = 1.5
var hit_counter: int = 0
var crumble_state: int = 0
var collected := false
var invincible := true
var quest: Quest


static func collect(target_pos: Vector3) -> void:
	var box = box_queue.pop_front()
	if is_instance_valid(box):
		box.quest.ended.disconnect(box.die)
		box.collected = true
		var time = abs(box.global_position.y - target_pos.y) / 10 + 0.3
		var tween_y = box.create_tween()
		tween_y.set_trans(Tween.TRANS_CIRC)
		tween_y.tween_property(box, "global_position:y", max(target_pos.y, box.global_position.y) + 3, time / 2).set_ease(Tween.EASE_OUT)
		tween_y.tween_property(box, "global_position:y", target_pos.y, time / 2).set_ease(Tween.EASE_IN)
		
		var tween = box.create_tween()
		tween.set_parallel(true)
		tween.tween_subtween(tween_y)
		tween.tween_property(box, "global_position:x", target_pos.x, time)
		tween.tween_property(box, "global_position:z", target_pos.z, time)
		tween.tween_property(box, "rotation:y", time * TAU * 2, time)
		tween.tween_property(box, "scale", Vector3.ONE * 0.001, time).set_ease(Tween.EASE_IN)
		tween.set_parallel(false)
		tween.tween_callback(box.queue_free)
	if box_queue.size() > 0:
		box_queue.front().target = Player.instance.tail


func _ready() -> void:
	if box_queue.size() == 0:
		target = Player.instance.tail
	else:
		target = box_queue.back()
	box_queue.append(self)
	
	Player.instance.damaged.connect(damage)
	Player.instance.died.connect(die)
	var rot = randi_range(0, 4) * TAU / 4
	$BoxCrumbled1.rotation.y = rot
	$BoxCrumbled2.rotation.y = rot
	$BoxCrumbled3.rotation.y = rot
	scale = Vector3.ONE * .001
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector3.ONE, 2).set_ease(Tween.EASE_OUT)
	tween.tween_callback(set.bind("invincible", false))
	quest.ended.connect(die.unbind(1))


func _process(delta: float) -> void:
	if collected:
		return
	var target_pos = target.global_position
	look_at(target_pos)
	var distance = global_position.distance_to(target_pos)
	if distance > max_distance:
		global_position = global_position.move_toward(target_pos, (distance - max_distance) * delta * 10) 
	global_position.y -= delta * 4


func damage() -> void:
	if collected or invincible:
		return
	hit_counter += 1
	crumble_state = floor(float(hit_counter) / hits_to_crumble)
	$Box.visible = crumble_state == 0
	$BoxCrumbled1.visible = crumble_state == 1
	$BoxCrumbled2.visible = crumble_state == 2
	$BoxCrumbled3.visible = crumble_state >= 3
	if crumble_state > 3:
		die()
		quest.end_quest(Quest.EndState.BROKEN)


func die() -> void:
	if collected:
		return
	box_queue.erase(self)
	if quest.ended.is_connected(die):
		quest.ended.disconnect(die)
	var time: float = 2.5
	var tween_y = create_tween()
	tween_y.set_trans(Tween.TRANS_CIRC)
	tween_y.tween_property(self, "global_position:y", global_position.y + 3, time * .1).set_ease(Tween.EASE_OUT)
	tween_y.tween_property(self, "global_position:y", global_position.y - 20, time * .9).set_ease(Tween.EASE_IN)
	
	var target_pos: Vector3 = global_position + Vector3.FORWARD.rotated(Vector3.UP, randf() * TAU) * 10
	var tween = self.create_tween()
	tween.set_parallel(true)
	tween.tween_subtween(tween_y)
	tween.tween_property(self, "global_position:x", target_pos.x, time)
	tween.tween_property(self, "global_position:z", target_pos.z, time)
	tween.tween_property(self, "rotation:y", time * TAU * 2, time).set_trans(Tween.TRANS_LINEAR)
	tween.set_parallel(false)
	tween.tween_callback(queue_free)
