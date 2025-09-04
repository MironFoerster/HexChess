extends Control

signal remove_requested

func _on_remove_button_pressed() -> void:
	remove_requested.emit()
