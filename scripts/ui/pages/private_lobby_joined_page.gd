extends Control



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$JoinCodeLabel.text = "Game Code: " + str(BattleManager.battle.game_code)
	BattleManager.battle.player_added.connect(_on_player_added)
	BattleManager.battle.battle_started.connect(_on_battle_started)


func _on_player_added():
	$VBoxContainer/NumPlayersLabel.text = "Number of Players: " + str(BattleManager.battle.players.size())

func _on_battle_started():
	pass

func _on_leave_game_button_pressed() -> void:
	SceneManager.page_transition_to("online_home")
