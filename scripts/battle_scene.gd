extends Node2D
class_name BattleScene

var unit_scene = load("res://scenes/game/unit.tscn") as PackedScene
var tile_highlight_scene = load("res://scenes/ui/components/TileHighlight.tscn") as PackedScene
@onready var map_node = $"Map"
@onready var highlight_map_node = $"HighlightMap"
@onready var units_node = $"Units"
@onready var active_unit_panel = $"HUDLayer/HUDRoot/ActiveUnitPanel"

var unit_nodes_by_id: Dictionary[int, Node2D]
var unit_ids_by_owner: Dictionary[int, Array]  # owner_id->[unit_id1, unit_id2]

var active_unit_id: int
var active_ability_type: Types.AbilityType

func _ready():
	BattleManager.battle_set.connect(_on_battle_set)
	active_unit_panel.ability_clicked.connect(_on_ability_clicked)
	
func _on_battle_set():
	BattleManager.battle.battle_started.connect(_on_battle_started)
	BattleManager.battle.effect_tree_applied.connect(_on_effect_tree_applied)





### HANDLERS FOR BATTLE SIGNALS ###
func _on_battle_started():
	print("Battle started!")
	_rebuild_map()
	#_rebuild_battle_scene() TODO need to wait for all relevant things to be ready like map
	

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
	
func set_active_unit(unit: BattleUnit):
	active_unit_panel.set_unit(unit)
	
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
	var unit_instance: Node2D = unit_scene.instantiate()
	unit_instance.initialize(effect.data.unit)
	
	# add unit_instance to indices
	unit_nodes_by_id[effect.data.unit.unit_id] = unit_instance
	if !unit_ids_by_owner.has(effect.data.unit.owner_id):
		unit_ids_by_owner[effect.data.unit.owner_id] = []
	unit_ids_by_owner[effect.data.unit.owner_id].append(effect.data.unit.unit_id)
	
	# connect to clicked signal of unit_instance
	unit_instance.clicked.connect(_on_unit_clicked)
	# add unit_instance to scene
	units_node.add_child(unit_instance)
	
	return get_tree().create_timer(effect.duration/10.0).timeout
	
func _on_unit_clicked(unit_id: int):
	active_unit_id = unit_id
	active_unit_panel.set_unit(unit_id)
	
func _on_ability_clicked(ability_type: Types.AbilityType):
	if DataCatalog.abilities[ability_type].is_instant:
		BattleManager.submit_command(Command.new("ability", Vector2i(0,0), {
			"ability_type": ability_type,
			"unit_id": active_unit_id
		} ))
	else:
		for c in highlight_map_node.get_children():
			c.queue_free()
		
		var allowed_coords: Array[Vector2i] = BattleManager.battle.get_ability_allowed_cells(active_unit_id, ability_type)
		
		active_ability_type = ability_type
		
		for coords in allowed_coords:
			var t_h_instance: Node2D = tile_highlight_scene.instantiate()
			t_h_instance.initialize(coords)
			
			t_h_instance.clicked.connect(_on_tile_highlight_clicked)
			highlight_map_node.add_child(t_h_instance)

func _on_tile_highlight_clicked(coords: Vector2i):
	BattleManager.submit_command(Command.new("ability", Vector2i(0,0), {
			"ability_type": active_ability_type,
			"unit_id": active_unit_id,
			"target_coords": coords
		} ))
		
	#TODO reset ui after click
	
func _on_end_turn_button_pressed() -> void:
	GlobalNetworking.end_turn()


func _on_spawn_unit_button_pressed() -> void:
	BattleManager.submit_command(Command.new("spawn_unit", Vector2i(0,0), {"unit_dict": BattleUnit.new(Types.UnitType.WARRIOR, Vector2i(0,0), GameManager.player.player_id).to_dict()}))
