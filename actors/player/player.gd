class_name Player
extends CharacterBody3D

signal damaged
signal died
signal respawned
signal passenger_changed(Character)

static var instance: Player

@export var forward_speed: float = 15.0
@export var boosting_speed: float = 20.0
@export var braking_speed: float = 10.0
@export var vertical_speed: float = 15.0
@export var turning_speed: float = 2.0
@export var max_pitch: float = PI / 2 * .8
@export var max_height: float = 10.0
@export var downwards_force: float = 30.0

@export_group("Abilities")
@export var max_health: int = 50
@export var has_boost := true
@export var has_brake := true
@export var has_wing_retract := true
@export var has_second_seat := true

var current_max_height: float = 10.0
var current_max_height_soft: float = 10.0
var is_boosting: float = 0.0
var is_braking: float = 0.0
var is_retracted := false
var _turning_speed: float = 0.0
var _flight_velocity := Vector3.ZERO
var _drift_velocity := Vector3.ZERO
var _collision_velocity := Vector3.ZERO
var _shake_noise := FastNoiseLite.new()
var _shake_intensity: float = 0.0
var _wing_rhealth: int = 10
var _wing_lhealth: int = 10
var _invincibility_timer: float = 1.0

@onready var health: int = max_health
@onready var tail : Node3D = %Tail
@onready var _speed: float = forward_speed
@onready var _spawn_point: Vector3 = global_position
@onready var _spawn_basis: Basis = global_basis


func _ready() -> void:
	instance = self
	tail = %Tail


func _physics_process(delta: float) -> void:
	if health <= 0:
		return
	
	is_retracted = has_wing_retract and Input.is_action_pressed("retract_wings")
	if not is_retracted:
		process_flight_control(delta)
	else:
		_flight_velocity.y -= delta * 10
		rotation.x = _flight_velocity.y / vertical_speed
		rotation.z = move_toward(rotation.z, 0, delta)
	
	_invincibility_timer -= delta
	if _invincibility_timer <= 0:
		process_collisions()
	
	if _shake_intensity > 0:
		_shake_intensity -= delta
		%PlaneModel.rotation.z = _shake_noise.get_noise_1d(Time.get_ticks_msec() / 5.0) * pow(_shake_intensity, 3) * 1
		%PlaneModel.rotation.x = _shake_noise.get_noise_1d(Time.get_ticks_msec() / 5.0 + 20) * pow(_shake_intensity, 3) * 1
		%PlaneModel.rotation.y = _shake_noise.get_noise_1d(Time.get_ticks_msec() / 5.0 + 40) * pow(_shake_intensity, 3) * 1
	else:
		%PlaneModel.rotation = Vector3.ZERO
	process_wing_state(delta)
	
	_collision_velocity = _collision_velocity.move_toward(Vector3.ZERO, delta * 100)
	velocity = _flight_velocity + _drift_velocity + _collision_velocity
	process_max_height(delta)
	move_and_slide()
	
	%PlaneModel.propeller_speed = _speed * 1.5
	%PlaneModel.wings_retracted = is_retracted
	%PlaneModel.second_seat = has_second_seat
	if health <= 0:
		die()


func die() -> void:
	%PlaneModel.visible = false
	%Explosion.emitting = true
	get_tree().create_timer(2, true, false).timeout.connect(respawn.call_deferred)
	if is_instance_valid(Quest.active_quest):
		Quest.active_quest.end_quest(Quest.EndState.CRASH)
	died.emit()


func respawn() -> void:
	global_position = _spawn_point
	global_basis = _spawn_basis
	health = max_health
	_flight_velocity = Vector3.ZERO
	_drift_velocity = Vector3.ZERO
	_collision_velocity = Vector3.ZERO
	_shake_intensity = 0
	_invincibility_timer = 1.0
	_wing_rhealth = 10
	_wing_lhealth = 10
	%PlaneModel.visible = true
	respawned.emit()


func process_flight_control(delta: float) -> void:
	var base_speed: float = forward_speed
	if has_boost:
		is_boosting = Input.get_action_strength("boost")
		base_speed = lerp(base_speed, boosting_speed, is_boosting)
	else:
		is_boosting = 0.0
	if has_brake:
		is_braking = Input.get_action_strength("brake")
		base_speed = lerp(base_speed, braking_speed, is_braking)
	else:
		is_braking = 0.0
	_speed = move_toward(_speed, base_speed, delta * (10 + min(1, is_braking + is_boosting) * 10))
	_flight_velocity = Vector3.FORWARD.rotated(Vector3.UP, rotation.y) * _speed
	_flight_velocity.y = rotation.x * vertical_speed
	var target_rotation = Input.get_axis("turn_right", "turn_left") * turning_speed
	_turning_speed = move_toward(_turning_speed, target_rotation, 10 * delta)
	rotate_y(_turning_speed * delta)
	var target_angle = Input.get_axis("turn_up", "turn_down") * max_pitch
	rotation.x = move_toward(rotation.x, target_angle, turning_speed * delta)
	rotation.z = _turning_speed * .3


func process_collisions() -> void:
	var damage = 0
	if not is_retracted:
		if $WingRCol.has_overlapping_bodies():
			_wing_rhealth -= 1
			damage += 1 if _wing_rhealth > 0 else 3
			_collision_velocity = -basis.x * 20
		if $WingLCol.has_overlapping_bodies():
			_wing_lhealth -= 1
			damage += 1 if _wing_lhealth > 0 else 3
			_collision_velocity = basis.x * 20
	if $TopCol.has_overlapping_bodies():
		damage += 3
		_collision_velocity = Vector3.DOWN * 20
	if $BottomCol.has_overlapping_bodies():
		damage += 3
		_collision_velocity = Vector3.UP * 20
	if is_on_wall():
		damage += 3
		_collision_velocity = basis.z * 40
	if damage > 0:
		do_damage(damage)


func do_damage(amount: int = 3) -> void:
	health -= amount
	damaged.emit()
	_invincibility_timer = .1
	_shake_intensity = 1.0


func process_wing_state(delta: float) -> void:
	var new_velocity = Vector3.ZERO
	if _wing_rhealth <= 0:
		%PlaneModel.wing_r_health = 0
		new_velocity += basis.x * 5 + Vector3.DOWN * 2
		rotation.z -= .5
	elif _wing_rhealth <= 5:
		%PlaneModel.wing_r_health = 1
		new_velocity += basis.x * 2 + Vector3.DOWN
		rotation.z -= .3
	else:
		%PlaneModel.wing_r_health = 2
	if _wing_lhealth <= 0:
		%PlaneModel.wing_l_health = 0
		new_velocity += -basis.x * 5 + Vector3.DOWN * 2
		rotation.z += .5
	elif _wing_lhealth <= 5:
		%PlaneModel.wing_l_health = 1
		new_velocity += -basis.x * 2 + Vector3.DOWN
		rotation.z += .3
	else:
		%PlaneModel.wing_l_health = 2
	_drift_velocity = _drift_velocity.move_toward(new_velocity, delta * 10)


func process_max_height(delta: float) -> void:
	var new_max_height = max_height
	for b: HeightOverride in %Interaction.get_overlapping_areas():
		new_max_height = max(new_max_height, b.new_max_height)
	current_max_height = max(current_max_height, new_max_height)
	current_max_height = move_toward(current_max_height, new_max_height, delta * 5)
	current_max_height_soft = current_max_height - 8
	if global_position.y > current_max_height_soft:
		velocity.y -= ease(remap(global_position.y, current_max_height_soft, current_max_height, 0, 1), 3) * downwards_force


func set_passenger(character: Character) -> void:
	if character:
		%PassengerHead.texture = character.portrait
	else:
		%PassengerHead.texture = null
	passenger_changed.emit(character)
