class_name CoinQuest
extends Quest

@export var coin_requirement = 10

func start_quest(source: Node3D) -> bool:
	if not super(source):
		return false
	Globals.quest_coins = 0
	return true


func try_goal(source: Node3D) -> EndState:
	if Globals.quest_coins >= coin_requirement:
		return super(source)
	else:
		return EndState.CUSTOM1
