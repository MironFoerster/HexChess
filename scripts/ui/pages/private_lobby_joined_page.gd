extends Control


signal request_page_change(page_name)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$JoinCodeLabel.text = "Game Code: " + str(GlobalNetworking.session.game_code)
	GlobalNetworking.session.player_added.connect(_on_player_added)

func _on_player_added():
	$VBoxContainer/NumPlayersLabel.text = "Number of Players: " + str(GlobalNetworking.session.players.size())



func _on_leave_game_button_pressed() -> void:
	request_page_change.emit("online_home")
