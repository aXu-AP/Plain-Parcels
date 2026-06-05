extends Control

var _timer: SceneTreeTimer

func _process(delta: float) -> void:
	if is_instance_valid(_timer):
		%TimerLabel.visible = true
		%TimerLabel.text = str(ceili(_timer.time_left))
		if _timer.time_left == 0:
			var tween = create_tween()
			tween.tween_property(%TimerLabel, "scale:y", 0, 0.15)
			tween.tween_callback(self.set.bind("_timer", null))
	else:
		%TimerLabel.visible = false
	if is_instance_valid(Player.instance):
		%HealthBar.max_value = Player.instance.max_health
		%HealthBar.custom_minimum_size.x = Player.instance.max_health * 5
		%HealthBar.value = Player.instance.health
	%CoinLabel.text = "%03d" % Globals.coins


func connect_timer(timer: SceneTreeTimer) -> void:
	_timer = timer
	%TimerLabel.scale.y = 0
	var tween = create_tween()
	tween.tween_property(%TimerLabel, "scale:y", 1, 0.15)
