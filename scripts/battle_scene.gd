extends Node2D
class_name BattleScene

var unit_scene = load("res://scenes/game/unit.tscn") as PackedScene
@onready var map_node = $"./Map"
@onready var highlight_map_node = $"./HighlightMap"
@onready var units_node = $"./Units"

var unit_nodes_by_id: Dictionary[int, Node2D]
var unit_ids_by_owner: Dictionary[int, Array]  # owner_id->[unit_id1, unit_id2]


func _ready():
	BattleManager.battle_set.connect(_on_battle_set)
	
func _on_battle_set():
	BattleManager.battle.battle_started.connect(_on_battle_started)
	BattleManager.battle.map_updated.connect(_on_map_updated)
	BattleManager.battle.effect_tree_applied.connect(_on_effect_tree_applied)
	
func _on_battle_started():
	print("Battle started!")
	_start_battle_setup()
	#_rebuild_battle_scene() TODO need to wait for all relevant things to be ready like map

func _on_map_updated():
	print("Map updated!")
	_rebuild_map()
	

func _on_effect_tree_applied(effect_tree: Effect):
	render_effect_tree(effect_tree)
	
func render_effect_tree(effect: Effect):
	print("Rendering Effect!")
	match effect.effect_type:
		"spawn_unit":
			await _spawn_unit(effect)
	
	for child_effect in effect.child_effects:
		print("entering child")
		render_effect_tree(child_effect)
		
func _start_battle_setup():
	pass
	
func _rebuild_battle_scene():
	_rebuild_map()
	_rebuild_units()

func _get_atlas_coords_from_cell(cell: Cell) -> Vector2i:
	return Vector2i(0,0) #TODO
	
func _rebuild_map():
	map_node.clear()
	
	for coords in BattleManager.battle.map.cells.keys():
		var atlas_coords = DataCatalog.terrains[BattleManager.battle.map.cells.get(coords).terrain_type].atlas_coords
		map_node.set_cell(coords, 0, atlas_coords)
	
func _rebuild_units():
	for child in units_node.get_children():
		units_node.remove_child(child)
		child.queue_free()
		
	for unit in BattleManager.battle.units:
		var unit_node = unit_scene.instantiate()
		unit_node.initialize(unit)
		units_node.add_child(unit_node)

func _spawn_unit(effect: Effect) -> Signal:
	print("spawning")
	var unit_instance: Node2D = unit_scene.instantiate()
	unit_instance.initialize(effect.data.unit)
	unit_nodes_by_id[effect.data.unit.unit_id] = unit_instance
	if !unit_ids_by_owner.has(effect.data.unit.owner_id):
		unit_ids_by_owner[effect.data.unit.owner_id] = []
	unit_ids_by_owner[effect.data.unit.owner_id].append(effect.data.unit.unit_id)
	
	units_node.add_child(unit_instance)
	
	return get_tree().create_timer(effect.duration/10.0).timeout
	
func _on_end_turn_button_pressed() -> void:
	GlobalNetworking.end_turn()


func _on_spawn_unit_button_pressed() -> void:
	BattleManager.submit_command(Command.new("spawn_unit", Vector2i(0,0), {"unit_dict": Unit.new("warrior", Vector2i(0,0), GameManager.player.player_id).to_dict()}))
