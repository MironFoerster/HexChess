extends Control

@onready var mode_chooser = $VBoxContainer/AdminContainer/ChooseModeButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$JoinCodeLabel.text = "Game Code: " + str(GameManager.active_battle.game_code)
	$VBoxContainer/NumPlayersLabel.text = "Number of Players: 1"
	GameManager.active_battle.player_added.connect(_on_player_added)
	GameManager.active_battle.game_started.connect(_on_game_started)

func _on_player_added():
	$VBoxContainer/NumPlayersLabel.text = "Number of Players: " + str(GameManager.active_battle.players.size())
func _on_game_started():
	SceneManager.page_transition_to("none")
	
func _on_cancel_game_button_pressed() -> void:
	SceneManager.page_transition_to("online_home")

func _on_start_game_button_pressed() -> void:
	GlobalNetworking.start_battle(GameManager.active_battle.game_code)
	
#mode_chooser.get_item_text(mode_chooser.get_item_index(mode_chooser.get_selected_id()))
	
