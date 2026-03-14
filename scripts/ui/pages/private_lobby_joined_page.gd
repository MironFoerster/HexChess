extends Control



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$JoinCodeLabel.text = "Game Code: " + str(GameManager.active_battle.game_code)
	GameManager.active_battle.player_added.connect(_on_player_added)


func _on_player_added():
	$VBoxContainer/NumPlayersLabel.text = "Number of Players: " + str(GameManager.active_battle.players.size())


func _on_leave_game_button_pressed() -> void:
	SceneManager.page_transition_to("online_home")
