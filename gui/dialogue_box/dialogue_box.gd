extends PanelContainer

var _message_queue: Array[Message] = []
var _current_message: Message = null


func _ready() -> void:
	visible = false


func queue_message(message: Message) -> void:
	_message_queue.append(message)
	if _message_queue.size() == 1 and _current_message == null:
		_show_next_message()


func _show_next_message():
	if _message_queue.size() == 0:
		_current_message = null
		visible = false
		return
	visible = true
	var message = _message_queue.pop_front()
	%DialogueText.text = message.text
	%DialogueText.visible_characters = 0
	if message.character:
		%Portrait.texture = message.character.portrait
	else:
		%Portrait.texture = null
	scale.y = 0
	var tween = create_tween()
	tween.tween_property(self, "scale:y", 1, 0.15)
	tween.tween_interval(.3)
	var chars = %DialogueText.get_total_character_count()
	tween.tween_method(_show_characters, 0, chars, chars * 0.03)
	tween.tween_interval(message.duration)
	tween.tween_property(self, "scale:y", 0, 0.15)
	tween.tween_callback(_show_next_message)
	_current_message = message


func _show_characters(count: int):
	if count > %DialogueText.visible_characters:
		%DialogueText.visible_characters = count
		# TODO: Animation and sound?
