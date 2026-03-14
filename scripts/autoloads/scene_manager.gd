extends Node

@onready var page_container: Control = get_tree().current_scene.get_node("UILayer/PageContainer")
@onready var battle_container: Node2D = get_tree().current_scene.get_node("BattleContainer")

var page_scenes = {
	"ident": preload("res://scenes/ui/pages/IdentPage.tscn"),
	"online_home": preload("res://scenes/ui/pages/OnlineHomePage.tscn"),
	"local_home": preload("res://scenes/ui/pages/LocalHomePage.tscn"),
	"options": preload("res://scenes/ui/pages/OptionsPage.tscn"),
	"units": preload("res://scenes/ui/pages/UnitsPage.tscn"),
	"battle": preload("res://scenes/ui/pages/IngamePage.tscn"),
	"private_lobby_joined": preload("res://scenes/ui/pages/PrivateLobbyJoinedPage.tscn"),
	"private_lobby_admin": preload("res://scenes/ui/pages/PrivateLobbyAdminPage.tscn"),
}
var cached_pages: = {}
var current_page: Control
var tween: Tween


func _ready():
	page_transition_to("ident")

func page_transition_to(name: String, duration: float = 1):
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


func _hide_any_old_pages():
	# Keep current visible; old ones get hidden
	for child in page_container.get_children():
		if child != current_page:
			child.visible = false
			page_container.remove_child(child)
