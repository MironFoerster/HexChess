extends Control


signal request_page_change(page_name)


func _on_options_button_pressed() -> void:
	request_page_change.emit("options")


func _on_exit_button_pressed() -> void:
	get_tree().quit()


func _on_play_local_button_pressed() -> void:
	request_page_change.emit("ingame")
	GlobalAudio.switch_music_to("game")
