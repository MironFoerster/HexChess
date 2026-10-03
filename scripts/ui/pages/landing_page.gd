extends Control


func _on_local_button_pressed() -> void:
	SceneManager.page_transition_to("none")
	LobbyManager.create_player()
	BattleManager.set_battle(Battle.new(false, "private", -1, {}))
	BattleManager.start_battle()


func _on_create_party_button_pressed() -> void:
	GlobalNetworking.create_private_room()


func _on_join_party_button_pressed() -> void:
	GlobalNetworking.join_private_room(int($JoinOrCreateContainer/JoinCodeInput.text))


func _on_ranked_button_pressed() -> void:
	SceneManager.page_transition_to("ident")


func _on_campaign_button_pressed() -> void:
	pass # Replace with function body.
	
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
