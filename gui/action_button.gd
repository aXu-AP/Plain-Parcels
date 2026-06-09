extends Button

## Target node. Leave empty for calling GameManager.
@export var target : Node
@export var method : String
@export var parameters : Array

@export var grab_focus_on_visible : bool


func _ready() -> void:
	if not is_instance_valid(target):
		target = GameManager
	if target.has_method(method):
		pressed.connect(Callable(target, method).bindv(parameters))
	
	visibility_changed.connect(try_grab_focus)
	try_grab_focus()


func try_grab_focus():
	if visible and grab_focus_on_visible:
		grab_focus()
