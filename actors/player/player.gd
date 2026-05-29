class_name Player
extends CharacterBody3D

signal died
signal respawned

@export var max_health: int = 50
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
var _extra_velocity := Vector3.ZERO
var _shake_noise := FastNoiseLite.new()
var _shake_intensity: float = 0.0
var _wing_rhealth: int = 10
var _wing_lhealth: int = 10
var _invincibility_timer: float = 1.0
@onready var health: int = max_health
@onready var _speed: float = forward_speed
@onready var _spawn_point: Vector3 = global_position
@onready var _spawn_basis: Basis = global_basis


func _ready() -> void:
	%HealthBar.max_value = max_health


func _physics_process(delta: float) -> void:
	if health <= 0:
		return
	
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
	
	_invincibility_timer -= delta
	if _invincibility_timer <= 0:
		if _wing_rhealth > 0 and $WingRCol.has_overlapping_bodies():
			health -= 1
			_invincibility_timer = .1
			_wing_rhealth -= 1
			_extra_velocity = -basis.x * 20
			_shake_intensity = 1.0
		if _wing_lhealth > 0 and $WingLCol.has_overlapping_bodies():
			_invincibility_timer = .1
			health -= 1
			_wing_lhealth -= 1
			_extra_velocity = basis.x * 20
			_shake_intensity = 1.0
		if $TopCol.has_overlapping_bodies():
			_invincibility_timer = .1
			health -= 3
			_extra_velocity = Vector3.DOWN * 20
			_shake_intensity = 1.0
		if $BottomCol.has_overlapping_bodies():
			_invincibility_timer = .1
			health -= 3
			_extra_velocity = Vector3.UP * 20
			_shake_intensity = 1.0
		if is_on_wall():
			health -= 3
			_extra_velocity = basis.z * 40
			_shake_intensity = 1.0
	
	if _shake_intensity > 0:
		_shake_intensity -= delta
		%Model.rotation.z = _shake_noise.get_noise_1d(Time.get_ticks_msec() / 5.0) * pow(_shake_intensity, 3) * 1
		%Model.rotation.x = _shake_noise.get_noise_1d(Time.get_ticks_msec() / 5.0 + 20) * pow(_shake_intensity, 3) * 1
		%Model.rotation.y = _shake_noise.get_noise_1d(Time.get_ticks_msec() / 5.0 + 40) * pow(_shake_intensity, 3) * 1
	else:
		%Model.rotation = Vector3.ZERO
	
	var target_extra_velocity = Vector3.ZERO
	if _wing_rhealth <= 0:
		%WingRBroken.visible = false
		target_extra_velocity += basis.x * 5 + Vector3.DOWN * 2
		rotation.z -= .5
	elif _wing_rhealth <= 5:
		%WingR.visible = false
		%WingRBroken.visible = true
		target_extra_velocity += basis.x * 2 + Vector3.DOWN
		rotation.z -= .3
	if _wing_lhealth <= 0:
		%WingLBroken.visible = false
		target_extra_velocity += -basis.x * 5 + Vector3.DOWN * 2
		rotation.z += .5
	elif _wing_lhealth <= 5:
		%WingL.visible = false
		%WingLBroken.visible = true
		target_extra_velocity += -basis.x * 2 + Vector3.DOWN
		rotation.z += .3
	
	_extra_velocity = _extra_velocity.move_toward(target_extra_velocity, delta * 100)
	velocity += _extra_velocity
	move_and_slide()
	
	%HealthBar.value = max(0, health)
	if health <= 0:
		die()


func die() -> void:
	%Model.visible = false
	%Explosion.emitting = true
	get_tree().create_timer(2, true, false).timeout.connect(respawn.call_deferred)
	died.emit()


func respawn() -> void:
	global_position = _spawn_point
	global_basis = _spawn_basis
	health = max_health
	_extra_velocity = Vector3.ZERO
	_shake_intensity = 0
	_invincibility_timer = 1.0
	_wing_rhealth = 10
	_wing_lhealth = 10
	%Model.visible = true
	%WingR.visible = true
	%WingRBroken.visible = false
	%WingL.visible = true
	%WingLBroken.visible = false
	respawned.emit()
