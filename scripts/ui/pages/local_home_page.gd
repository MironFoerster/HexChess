extends Control

signal request_page_change(page_name)
signal request_play_mode(mode, is_local, map_config, players, )

var player_card_scene = preload("res://scenes/ui/components/local_player_edit_card.tscn")
var gamemode_card_scene = preload("res://scenes/ui/components/gamemode_card.tscn")

@onready var player_container = $PlayersSetupContainer
@onready var gamemodes_container = $GamemodesContainer

const local_gamemodes: Dictionary[StringName, Dictionary] = {
	"nice_mode": {"title": "Nice Mode",
	"description": "lulu lala",
	"icon_path": "res://assets/placeholder.png"}
}

func _ready() -> void:
	for mode in local_gamemodes.keys():
		var gamemode_card = gamemode_card_scene.instantiate()
		gamemode_card.initialize(local_gamemodes[mode])
		gamemode_card.request_play_mode.connect(_on_request_play_mode.bind(mode))
	
func _on_request_play_mode(mode_name: String):
	GlobalNetworking.request_start_session_game(mode_name)

func _on_add_player_button_pressed() -> void:
	var player_card = player_card_scene.instantiate()
	player_card.remove_requested.connect(_on_remove_requested.bind(player_card))
	player_container.add_child(player_card)
	
func _on_remove_requested(card):
	card.queue_free()
