extends Control

signal request_page_change(page_name)


func _on_nickname_link_button_pressed() -> void:
	$PlayOnlineContainer/LoginTabContainer.current_tab = 0

func _on_login_link_button_pressed() -> void:
	$PlayOnlineContainer/LoginTabContainer.current_tab = 1

func _on_register_link_button_pressed() -> void:
	$PlayOnlineContainer/LoginTabContainer.current_tab = 2
