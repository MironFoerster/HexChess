extends Node

@onready var game := get_parent() as Game
var pressed: Node3D
var action_mode: String = "move"
var tile_highlights: Dictionary = {
	"selected": null,
	"hovered": null,
	"targetable": [],
}

#func ripple (tile: Node3D) -> void:
	#for distance in range(map_radius*2 +1):
		#for t in $Tiles.get_children():
			#if t.coordinates.distance_to(tile.coordinates) == distance:
				#t.toggle_highlight()
				##t.get_node("AnimationPlayer").play("bump")
		#await get_tree().create_timer(0.06).timeout

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event) -> void:
	if event is InputEventKey:
		if event.keycode == KEY_SHIFT:  # Detect any Shift key
			if event.pressed and not event.echo:  # Pressed (no repeats)
				action_mode = "affect"
			elif not event.pressed:  # Released
				action_mode = "move"


func _unhandled_input(event) -> void:
	if event is InputEventMouseMotion:
		tile_highlights.hovered = null

func pressed_on(tile: Node3D) -> void:
	if tile_highlights.selected != null:
		if tile_highlights.selected != tile:
			if action_mode == "move" and tile in tile_highlights.movable:
				game.request_take_action.emit(tile_highlights.selected, tile, "move")
			elif action_mode == "affect" and tile in tile_highlights.affectable:
				game.take_action.emit(tile_highlights.selected, tile, "affect")
			
			tile_highlights.selected = null
			hovered_on(tile)
		else:
			return
	else:
		tile_highlights.selected = tile
		tile_highlights.hovered = tile
		
		
	tile_highlights.selected = tile
	game.update_highlights.emit()
	
func hovered_on(tile: Node3D) -> void:
	if tile_highlights.hovered != tile:
		tile_highlights.hovered = tile
		game.update_highlights.emit()
