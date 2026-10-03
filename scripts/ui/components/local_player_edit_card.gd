extends Control

signal remove_requested

func initialize(_player: Player):
	$VBoxContainer/NicknameLineEdit.text = _player.name

func _on_remove_button_pressed() -> void:
	remove_requested.emit()
