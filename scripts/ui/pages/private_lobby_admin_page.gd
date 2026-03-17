extends Control

@onready var mode_chooser = $VBoxContainer/AdminContainer/ChooseModeButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$JoinCodeLabel.text = "Game Code: " + str(BattleManager.battle.game_code)
	$VBoxContainer/NumPlayersLabel.text = "Number of Players: 1"
	BattleManager.battle.player_added.connect(_on_player_added)
	BattleManager.battle.battle_started.connect(_on_battle_started)

func _on_player_added():
	$VBoxContainer/NumPlayersLabel.text = "Number of Players: " + str(BattleManager.battle.players.size())

func _on_battle_started():
	pass
	
func _on_cancel_game_button_pressed() -> void:
	SceneManager.page_transition_to("online_home")

func _on_start_game_button_pressed() -> void:
	BattleManager.submit_start_battle()
	
#mode_chooser.get_item_text(mode_chooser.get_item_index(mode_chooser.get_selected_id()))
	
