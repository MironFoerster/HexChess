extends Control

func _on_home_button_pressed() -> void:
	# TODO: decide if local or online home
	SceneManager.page_transition_to("local_home")
	GlobalAudio.switch_music_to("home")
