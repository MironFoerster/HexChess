extends Control

@onready var mode_chooser = $VBoxContainer/AdminContainer/ChooseModeButton
signal request_page_change(page_name)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$JoinCodeLabel.text = "Game Code: " + str(GlobalNetworking.session.game_code)
	$VBoxContainer/NumPlayersLabel.text = "Number of Players: 1"
	GlobalNetworking.session.player_added.connect(_on_player_added)
	GlobalNetworking.session.game_started.connect(_on_game_started)

func _on_player_added():
	$VBoxContainer/NumPlayersLabel.text = "Number of Players: " + str(GlobalNetworking.session.players.size())
func _on_game_started():
	request_page_change.emit("none")
	
func _on_cancel_game_button_pressed() -> void:
	request_page_change.emit("online_home")

func _on_start_game_button_pressed() -> void:
	GlobalNetworking.request_start_session_game(mode_chooser.get_item_text(mode_chooser.get_item_index(mode_chooser.get_selected_id())))
	
