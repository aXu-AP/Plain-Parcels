## SaveManager offers tools for saving data either for this session or permanent storage.
## Of note: you can change types of data dictionaries to custom resources.
class_name SaveManager
extends Node


## Use permanent_data to keep track of any progress that needs to be saved to the disk.
static var permanent_data : Dictionary = {}
## Use session_data to hold variables which need to move from scene to another, but not between sessions.
static var session_data : Dictionary = {}
## Backup of session_data from time make_checkpoint() was last called.
static var session_data_checkpoint : Dictionary


## Save permanent_data to disk.
static func save_game(path = "user://savegame.dat") -> void:
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(var_to_str(permanent_data))


## Load permanent_data from disk.
static func load_game(path = "user://savegame.dat") -> void:
	if FileAccess.file_exists(path):
		var file = FileAccess.open(path, FileAccess.READ)
		permanent_data = str_to_var(file.get_as_text())


## Backs up session_data.
static func make_checkpoint() -> void:
	session_data_checkpoint = session_data


## Restores session_data to earlier state.
## If no checkpoint exists, does nothing.
static func restore_checkpoint() -> void:
	if session_data_checkpoint:
		session_data = session_data_checkpoint
