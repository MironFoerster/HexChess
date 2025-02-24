extends Node

@onready var dragger: Node = $"../Dragger"
@onready var controller: Node = $"../GameController"
var pressed: Node3D
var action_mode: String = "move"
var tile_highlights: Dictionary = {
	"selected": null,
	"hovered": null,
	"movable": [],
	"affectable": []
}
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


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
	# former dragging code
	#if event is InputEventMouseButton:
		#if event.button_index == MOUSE_BUTTON_LEFT:
			#if !event.pressed: # release
				#pressed = null
				#dragger.end_dragging()

func _unhandled_input(event) -> void:
	if event is InputEventMouseMotion:
		tile_highlights.hovered = null

func pressed_on(tile: Node3D) -> void:
	if tile_highlights.selected != null:
		if tile_highlights.selected != tile:
			if action_mode == "move" and tile in tile_highlights.movable:
				controller.take_action.emit(tile_highlights.selected, tile, "move")
			elif action_mode == "affect" and tile in tile_highlights.affectable:
				controller.take_action.emit(tile_highlights.selected, tile, "affect")
			
			tile_highlights.selected = null
			hovered_on(tile)
		else:
			return
	else:
		tile_highlights.selected = tile
		tile_highlights.hovered = tile
		
		
	tile_highlights.selected = tile
	update_actable_highlights()
	controller.update_highlights.emit()
	
func hovered_on(tile: Node3D) -> void:
	if tile_highlights.hovered != tile:
		tile_highlights.hovered = tile
		update_actable_highlights()
		controller.update_highlights.emit()

func update_actable_highlights() -> void:
	if tile_highlights.selected != null:
		var tiles = $"../Tiles".get_children()
		for tile in tiles:
			if not tile == tile_highlights.selected:
				tile_highlights.movable.append(tile)
				tile_highlights.affectable.append(tile)
	else:
		tile_highlights.movable = []
		tile_highlights.affectable = []
		
#func released_on(piece: Node3D) -> void:
	#pressed = null

# former dragging code
#func exited_from(piece: Node3D) -> void:
	#if pressed == piece:
		#dragger.start_dragging(piece)
