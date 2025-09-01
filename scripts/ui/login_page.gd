extends Control

@onready var nickname = $PlayOnlineContainer/LoginTabContainer/NicknameContainer/HBoxContainer/NicknameLineEdit
@onready var login_username = $PlayOnlineContainer/LoginTabContainer/LoginContainer/UsernameLineEdit
@onready var login_password = $PlayOnlineContainer/LoginTabContainer/LoginContainer/PasswordLineEdit
@onready var register_username = $PlayOnlineContainer/LoginTabContainer/RegisterContainer/UsernameLineEdit
@onready var register_password = $PlayOnlineContainer/LoginTabContainer/RegisterContainer/PasswordLineEdit
@onready var register_password_repeat = $PlayOnlineContainer/LoginTabContainer/RegisterContainer/PasswordRepeatLineEdit

signal request_page_change(page_name)

func _ready() -> void:
	GlobalNetworking.ident_processed.connect(_on_ident_processed)

## TAB NAVIGATION
func _on_nickname_link_button_pressed() -> void:
	$PlayOnlineContainer/LoginTabContainer.current_tab = 0

func _on_login_link_button_pressed() -> void:
	$PlayOnlineContainer/LoginTabContainer.current_tab = 1

func _on_register_link_button_pressed() -> void:
	$PlayOnlineContainer/LoginTabContainer.current_tab = 2

## SUBMIT HANDLERS
func _on_nickname_submit_button_pressed() -> void:
	pass # Replace with function body.

func _on_login_submit_button_pressed() -> void:
	GlobalNetworking.login_user(login_username.text, login_password.text)

func _on_ident_processed(success: bool):
	_clear_all_inputs()
	if success:
		request_page_change.emit("home")

func _on_register_submit_button_pressed() -> void:
	pass # Replace with function body.


## UTIL
func _clear_all_inputs():
	nickname.clear()
	login_username.clear()
	login_password.clear()
	register_username.clear()
	register_password.clear()
	register_password_repeat.clear()
