extends Control

var _timer_tween: Tween

func _process(_delta: float) -> void:
	if is_instance_valid(Quest.active_quest) and is_instance_valid(Quest.active_quest.timer):
		if not %TimerLabel.visible:
			%TimerLabel.visible = true
			%TimerLabel.scale.y = 0
			_new_timer_tween()
			_timer_tween.tween_property(%TimerLabel, "scale:y", 1, 0.15)
		
		%TimerLabel.text = str(ceili(Quest.active_quest.timer.time_left))
	elif %TimerLabel.visible:
		_new_timer_tween()
		_timer_tween.tween_property(%TimerLabel, "scale:y", 0, 0.15)
		_timer_tween.tween_callback(%TimerLabel.set.bind("visible", false))
	if is_instance_valid(Player.instance):
		%HealthBar.max_value = Player.instance.max_health
		%HealthBar.custom_minimum_size.x = Player.instance.max_health * 5
		%HealthBar.value = Player.instance.health
	%CoinLabel.text = "%03d" % Globals.coins
	if Quest.active_quest is CoinQuest:
		%QuestCoinCounter.visible = true
		%QuestCoinLabel.text = "%03d" % Globals.quest_coins
	else:
		%QuestCoinCounter.visible = false


func _new_timer_tween() -> void:
	if is_instance_valid(_timer_tween):
		_timer_tween.kill()
	_timer_tween = create_tween()
