extends Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_home_button_pressed() -> void:
	# TODO: decide if local or online home
	SceneManager.page_transition_to("local_home")
	GlobalAudio.switch_music_to("home")
