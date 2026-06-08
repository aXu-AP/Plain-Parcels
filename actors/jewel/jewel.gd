extends Area3D

@export var quest_name: StringName
var connected := false
var last_damaged: int
var tween: Tween
var lerp_distance: float


func _ready() -> void:
	if quest_name in Globals.flags:
		queue_free()
	Player.instance.damaged.connect(player_damaged)


func _process(delta: float) -> void:
	rotation.y += PI * delta
	if connected:
		$Model.global_position = global_position.lerp(Player.instance.global_position, lerp_distance)


func _on_area_entered(_area: Area3D) -> void:
	if Time.get_ticks_msec() - last_damaged < 200:
		return
	connected = true
	lerp_distance = 0
	tween = create_tween()
	tween.tween_property(self, "lerp_distance", 1, 2).set_ease(Tween.EASE_OUT_IN).set_trans(Tween.TRANS_QUINT)
	tween.tween_callback(collect)


func player_damaged() -> void:
	last_damaged = Time.get_ticks_msec()
	connected = false
	if is_instance_valid(tween):
		tween.kill()


func collect() -> void:
	Globals.add_flag(quest_name)
	get_parent().remove_child(self)
	Player.instance.add_child(self)
	position = Vector3.ZERO
	tween = create_tween()
	$Model.position = Vector3.ZERO
	tween.tween_property($Model, "position:y", 3, 1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
	$CollectParticles.position = Vector3(0, 3, 0)
	tween.tween_callback($CollectParticles.set.bind("emitting", true))
	$Model.scale = Vector3.ONE * .5
	tween.tween_property($Model, "scale", Vector3.ZERO, .2).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	$CollectParticles.finished.connect(queue_free)
