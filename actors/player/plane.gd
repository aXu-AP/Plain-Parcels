extends Node3D

var propeller_speed: float = 10.0
var second_seat := true
var wing_r_health: int = 2
var wing_l_health: int = 2
var wings_retracted := false
var _wing_scale: float = 1.0
@onready var _wings: Array[Node3D] = [$WingR, $WingRBroken, $WingRBroken2, $WingL, $WingLBroken, $WingLBroken2]

func _process(delta: float) -> void:
	$Propeller.rotation.z += delta * propeller_speed
	$WingR.visible = wing_r_health == 2
	$WingRBroken.visible = wing_r_health == 1
	$WingRBroken2.visible = wing_r_health == 0
	$WingL.visible = wing_l_health == 2
	$WingLBroken.visible = wing_l_health == 1
	$WingLBroken2.visible = wing_l_health == 0
	$BackseatCover.visible = !second_seat
	_wing_scale = lerp(_wing_scale, 0.0 if wings_retracted else 1.0, delta * 10)
	for w: Node3D in _wings:
		w.scale.x = _wing_scale
