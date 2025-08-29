extends Control

@onready var page_container: Control = $PageContainer

var page_scenes = {
	"home": preload("res://packed_scenes/ui/home_page.tscn"),
	"options": preload("res://packed_scenes/ui/options_page.tscn"),
	"units": preload("res://packed_scenes/ui/units_page.tscn"),
	"ingame": preload("res://packed_scenes/ui/ingame_page.tscn"),
	"private_lobby_joined": preload("res://packed_scenes/ui/private_lobby_joined_page.tscn"),
	"private_lobby_admin": preload("res://packed_scenes/ui/private_lobby_admin_page.tscn"),
}
var cached_pages: = {}
var current_page: Control
var tween: Tween


func _ready():
	ui_transition_to("home")

func ui_transition_to(name: String, duration: float = 1):
	# Cancel any running transition
	if tween and tween.is_running():
		tween.kill()
		_hide_any_old_pages()

	var new_page: Control = null
	if name != "none":
		# Load or fetch from cache
		if cached_pages.has(name):
			new_page = cached_pages[name]
			if not new_page.get_parent(): # was removed before
				page_container.add_child(new_page)
		else:
			new_page = page_scenes[name].instantiate()
			new_page.request_page_change.connect(ui_transition_to)
			cached_pages[name] = new_page
			page_container.add_child(new_page)
		
		new_page.visible = false  # will fade in later

	tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	tween.tween_callback(Callable(self, "_hide_any_old_pages")).set_delay(duration)
	# Ensure we have a Tween node
	#tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_EXPO)
	
	if new_page != current_page:
		if new_page:  # if fade to a new page
			# fade in new page
			if current_page:
				current_page.modulate.a = 1.0
			
			new_page.modulate.a = 0.0
			new_page.visible = true
			tween.tween_property(new_page, "modulate:a", 1.0, duration)

		elif current_page:  # if fade to none
			# fade out old page
			tween.tween_property(current_page, "modulate:a", 0.0, duration)
	
	current_page = new_page
	

	#if new_page != current_page:
		#if new_page:
			#new_page.modulate.a = 0.0
			#new_page.visible = true
			#
		#var old_page = current_page
		#current_page = new_page
		#
		#tween.tween_method(
			#func(value):
				#if old_page:
					#old_page.modulate.a = 1.0 - value
				#if new_page:
					#new_page.modulate.a = value,
			#0.0, 1.0, duration
		#)
	


func _hide_any_old_pages():
	# Keep current visible; old ones get hidden
	for child in page_container.get_children():
		if child != current_page:
			child.visible = false
			page_container.remove_child(child)
