extends Control


signal request_page_change(page_name)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$JoinCodeLabel.text = "Game Code: " + str(GlobalNetworking.session.game_code)
	$VBoxContainer/NumPlayersLabel.text = "Number of Players: 1"
	GlobalNetworking.session.player_added.connect(_on_player_added)

func _on_player_added():
	$VBoxContainer/NumPlayersLabel.text = "Number of Players: " + str(GlobalNetworking.session.players.size())

func _on_cancel_game_button_pressed() -> void:
	request_page_change.emit("online_home")


func _on_start_game_button_pressed() -> void:
	request_page_change.emit("none")
	GlobalNetworking.request_start_session_game($VBoxContainer/AdminContainer/ChooseModeButton.get_item_text())
	
