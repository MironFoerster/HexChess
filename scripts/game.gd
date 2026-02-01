extends Node2D

var unit_scene = load("res://scenes/game/unit.tscn") as PackedScene
@onready var map_node = $"./Map"
@onready var highlight_map_node = $"./HighlightMap"
@onready var units_node = $"./Units"

var units_abilities_cache # TODO put this here or rather directly in session?

func _ready():
	GlobalNetworking.session.game_started.connect(_on_game_started)
	GlobalNetworking.session.map_updated.connect(_on_map_updated)
	GlobalNetworking.session.action_performed.connect(_on_action_performed)
	
func _on_set_session(session: Session):
	session = session
	_rebuild_game_scene()
	
func _on_game_started():
	_start_game_setup()
	_rebuild_game_scene()

func _on_map_updated():
	print("Map updated!")
	_rebuild_map()
	
func _start_game_setup():
	pass

func _on_action_performed(unit: Unit, action: Action, derived_effects: Array[Effect]):
	pass#TODO: perform actions
	
func _rebuild_game_scene():
	_rebuild_map()
	_rebuild_units()

func _get_atlas_coords_from_cell(cell: Cell) -> Vector2i:
	return Vector2i(0,0) #TODO
	
func _rebuild_map():
	map_node.clear()
	
	for coords in GlobalNetworking.session.map.keys():
		var atlas_coords = _get_atlas_coords_from_cell(GlobalNetworking.session.map.get(coords))
		map_node.set_cell(coords, 0, atlas_coords)
	
func _rebuild_units():
	for child in units_node.get_children():
		units_node.remove_child(child)
		child.queue_free()
		
	for unit in GlobalNetworking.session.units:
		var unit_node = unit_scene.instantiate()
		unit_node.initialize(unit)
		units_node.add_child(unit_node)

func spawn_unit(unit_data_id: String, owner_id: int, coordinates: Vector2) -> Node3D:
	
	if not unit_data_id in DataCatalog.units.keys():
		print("Unit type not found:", unit_data_id)
		return
		
	var unit_instance: Node3D = unit_scene.instantiate()
	unit_instance.initialize(unit_data_id, owner_id, coordinates)
	#unit_instance.call_deferred("set_name", "Piece")
	units_node.add_child(unit_instance)
	
	return unit_instance
	
func _on_end_turn_button_pressed() -> void:
	GlobalNetworking.request_end_turn()
