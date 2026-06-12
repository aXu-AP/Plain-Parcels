extends Control


func _ready() -> void:
	SaveManager.load_game()
	%AddressLineEdit.text = SaveManager.permanent_data.get("ap_last_ip", "archipelago.gg")
	%PortLineEdit.text = SaveManager.permanent_data.get("ap_last_port", "38281")
	%SlotLineEdit.text = SaveManager.permanent_data.get("ap_last_slot", "")
	%PasswordLineEdit.text = SaveManager.permanent_data.get("ap_last_password", "")
	%AddressLineEdit.grab_focus.call_deferred()
	var connector = APConnector.create()
	GameManager.add_child(connector)


func connect_to_ap() -> void:
	%ConnectButton.text = "Connecting..."
	%ConnectButton.disabled = true
	%AddressLineEdit.editable = false
	%PortLineEdit.editable = false
	%SlotLineEdit.editable = false
	%PasswordLineEdit.editable = false
	%StatusLabel.visible = false
	Archipelago.ap_connect(
		%AddressLineEdit.text,
		%PortLineEdit.text,
		%SlotLineEdit.text,
		%PasswordLineEdit.text
	)
	Archipelago.connected.connect(start_game)
	Archipelago.connectionrefused.connect(no_connection)
	SaveManager.permanent_data["ap_last_ip"] = %AddressLineEdit.text
	SaveManager.permanent_data["ap_last_port"] = %PortLineEdit.text
	SaveManager.permanent_data["ap_last_slot"] = %SlotLineEdit.text
	SaveManager.permanent_data["ap_last_password"] = %PasswordLineEdit.text
	SaveManager.save_game()


func start_game(_conn: ConnectionInfo, _json: Dictionary) -> void:
	await GameManager.start_game()
	queue_free()


func no_connection(_conn: ConnectionInfo, json: Dictionary) -> void:
	%ConnectButton.text = "Connect"
	%ConnectButton.disabled = false
	%AddressLineEdit.editable = true
	%PortLineEdit.editable = true
	%SlotLineEdit.editable = true
	%PasswordLineEdit.editable = true
	%StatusLabel.text = "Error: %s" % ", ".join(json.get("errors", ["Unknown"]))
	%StatusLabel.visible = true


func _on_rich_text_label_meta_clicked(meta: Variant) -> void:
	OS.shell_open(str(meta))


func _on_check_button_toggled(toggled_on: bool) -> void:
	%AddressLineEdit.secret = toggled_on
	%PortLineEdit.secret = toggled_on
	%PasswordLineEdit.secret = toggled_on


func _on_address_line_edit_focus_exited() -> void:
	if not get_node_or_null("%AddressLineEdit"):
		return
	var text: String = %AddressLineEdit.text
	var parts := text.rsplit(":", true, 1)
	if parts.size() == 2 and parts[1].is_valid_int():
		%AddressLineEdit.text = parts[0]
		%PortLineEdit.text = parts[1]
