class_name Player
extends CharacterBody3D

@export var forward_speed: float = 15.0
@export var boosting_speed: float = 20.0
@export var braking_speed: float = 10.0
@export var vertical_speed: float = 15.0
@export var turning_speed: float = 2.0
@export var max_pitch: float = PI / 2 * .8
@export var max_height: float = 10.0
@export var max_height_soft: float = 7.0
@export var downwards_force: float = 30.0


var _turning_speed: float = 0.0
@onready var _speed: float = forward_speed

func _physics_process(delta: float) -> void:
	var base_speed: float = forward_speed
	base_speed = lerp(base_speed, boosting_speed, Input.get_action_strength("boost"))
	base_speed = lerp(base_speed, braking_speed, Input.get_action_strength("brake"))
	_speed = move_toward(_speed, base_speed, delta * (10 + Input.get_action_strength("boost") * 10))
	velocity = Vector3.FORWARD.rotated(Vector3.UP, rotation.y) * _speed
	velocity.y = rotation.x * vertical_speed
	var target_rotation = Input.get_axis("turn_right", "turn_left") * turning_speed
	_turning_speed = move_toward(_turning_speed, target_rotation, 10 * delta)
	rotate_y(_turning_speed * delta)
	var target_angle = Input.get_axis("turn_up", "turn_down") * max_pitch
	rotation.x = move_toward(rotation.x, target_angle, turning_speed * delta)
	rotation.z = _turning_speed * .3
	if global_position.y > max_height_soft:
		velocity.y -= ease(remap(global_position.y, max_height_soft, max_height, 0, 1), 3) * downwards_force
	move_and_slide()
