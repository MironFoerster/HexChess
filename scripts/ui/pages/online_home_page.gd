extends Control


signal request_page_change(page_name)


func _ready() -> void:
	GlobalNetworking.create_private_room_processed.connect(_on_create_private_room_processed)
	GlobalNetworking.join_private_room_processed.connect(_on_join_private_room_processed)

func _on_options_button_pressed() -> void:
	request_page_change.emit("options")


func _on_exit_button_pressed() -> void:
	get_tree().quit()


func _on_play_local_button_pressed() -> void:
	request_page_change.emit("local_home")
	# TODO: do this on game start: GlobalAudio.switch_music_to("game")

func _on_create_button_pressed() -> void:
	GlobalNetworking.request_create_private_room()

func _on_create_private_room_processed(success):
	if success:
		request_page_change.emit("private_lobby_admin")
	else:
		pass


func _on_join_button_pressed() -> void:
	GlobalNetworking.request_join_private_room(int($JoinOrCreateContainer/JoinCodeInput.text))

func _on_join_private_room_processed(success):
	if success:
		request_page_change.emit("private_lobby_joined")
	else:
		pass


func _on_join_code_input_text_changed(new_text: String) -> void:
	var regex := RegEx.new()
	regex.compile(r"\d")  # Matches individual digits
	var matches := regex.search_all(new_text)
	
	var filtered := ""
	for match in matches:
		filtered += match.get_string()

	if filtered != new_text:
		$JoinOrCreateContainer/JoinCodeInput.text = filtered
		$JoinOrCreateContainer/JoinCodeInput.caret_column = 6
