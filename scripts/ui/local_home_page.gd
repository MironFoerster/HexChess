extends Control

var player_scene = preload("res://scenes/ui/components/local_player_edit_card.tscn")
@onready var player_container = $PlayersSetupContainer

func _on_add_player_button_pressed() -> void:
	var player_card = player_scene.instantiate()
	player_card.remove_requested.connect(_on_remove_requested.bind(player_card))
	player_container.add_child(player_card)
	
func _on_remove_requested(card):
	card.queue_free()
