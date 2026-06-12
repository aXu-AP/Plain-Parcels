extends Control


func _ready() -> void:
	SaveManager.load_game()
	%ContinueButton.visible = "flags" in SaveManager.permanent_data


func start_new_game() -> void:
	var connector: LocalConnector = load("uid://dgpps3fedepwt").new()
	GameManager.add_child(connector)
	GameManager.game_ended.connect(connector.quit)
	connector.start_new()
	GameManager.start_game()


func continue_game() -> void:
	var connector: LocalConnector = load("uid://dgpps3fedepwt").new()
	GameManager.add_child(connector)
	GameManager.game_ended.connect(connector.quit)
	connector.load_game()
	GameManager.start_game()


func play_archipelago() -> void:
	var ap_menu: Node = load("uid://ddu3ha85vnt3h").instantiate()
	add_sibling(ap_menu)
	visible = false
	ap_menu.tree_exited.connect(set.bind("visible", true))
