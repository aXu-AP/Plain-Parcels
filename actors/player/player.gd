extends CharacterBody3D

@export var speed: float = 15.0
@export var turning_speed: float = 2.0
@export var max_pitch: float = PI / 2 * .8
@export var max_height: float = 10.0
@export var max_height_soft: float = 7.0
@export var downwards_force: float = 30.0

var _turning_speed: float = 0.0
@onready var _speed: float = speed

func _physics_process(delta: float) -> void:
	_speed = move_toward(_speed, speed - rotation.x * 5, delta * 10)
	velocity = -basis.z * _speed
	var target_rotation = Input.get_axis("turn_right", "turn_left") * turning_speed
	_turning_speed = move_toward(_turning_speed, target_rotation, 10 * delta)
	rotate_y(_turning_speed * delta)
	var target_angle = Input.get_axis("turn_up", "turn_down") * max_pitch
	rotation.x = move_toward(rotation.x, target_angle, turning_speed * delta)
	rotation.z = _turning_speed * .3
	if global_position.y > max_height_soft:
		velocity.y -= ease(remap(global_position.y, max_height_soft, max_height, 0, 1), 3) * downwards_force
	move_and_slide()
