class_name BattleScene
extends Node2D

var SQUAD_SCENE: PackedScene = preload("res://scenes/game/squad.tscn") as PackedScene
var UNIT_SCENE: PackedScene = preload("res://scenes/game/unit.tscn") as PackedScene

@onready var map_node: MapScene = $"Map"
@onready var squads_node: Node = $"Squads"
@onready var active_unit_panel: ActiveUnitPanel = $"HUDLayer/HUDRoot/ActiveUnitPanel"
@onready var current_squad_label: Label = $"HUDLayer/HUDRoot/CurrentSquadLabel"

var squads: Dictionary[int, SquadScene]

var unit_nodes_by_id: Dictionary[int, Node2D]

var active_unit: UnitScene
var active_ability_type: Types.AbilityType

var initializer: Dictionary

func _ready():
	BattleManager.battle_set.connect(_on_battle_set)
	active_unit_panel.ability_clicked.connect(_on_ability_clicked)

func initialize(map_node: MapScene, squad_nodes: Dictionary[int, SquadScene]):
	initializer = {
		"map_node": map_node,
		"squad_nodes": squad_nodes,
	}

func _on_battle_set():
	BattleManager.battle.battle_started.connect(_on_battle_started)
	BattleManager.battle.new_turn.connect(_on_new_turn)
	BattleManager.battle.effect_tree_applied.connect(_on_effect_tree_applied)
	
	# find the correct map_node to use
	# and initialize it with data from the battle object
	if initializer["map_node"] == null:
		map_node = $"Map"
	else:
		map_node = initializer["map_node"]
	
	map_node.initialize(BattleManager.battle.map)
	
	
	# reuse or create squads and their units
	# and initialize all units
	# Note: no checks are done whether the ids of reused units/squads
	# actually match whats specified in the battle object, instead
	# existing units are just re-initialized
	# (initialization does not include position)
	# TODO have a starting position(grid coords) and spawn position (grid coords)
	# TODO where to calculate starting positions of existing units?
	# TODO fix the units/units_by_id different namings. all unit collections should be by id, right?
	var squad_units: Dictionary[int, Unit]
	
	# for every squad specified in the battle object
	for squad_id in BattleManager.battle.squads:
		# instantiate a new or reuse an existing squad_scene from the initialization
		var squad_scene: SquadScene
		if initializer["squad_nodes"].has(squad_id):
			squad_scene = initializer["squad_nodes"][squad_id]
		else:
			squad_scene = SQUAD_SCENE.instantiate()
			# initialization is only done for instanciated squad_scenes,
			# to preserve unit_scenes in reused squad_scenes
			squad_scene.initialize(squad_id, {})
		
		# for every unit specified for the current squad in the battle object
		squad_units = BattleManager.battle.squads[squad_id].units
		for unit_id in squad_units:
			# check if the squad_scene already has this unit, else instantiate a new one
			var unit_scene: UnitScene
			if not squad_scene.units.has(unit_id):
				unit_scene = UNIT_SCENE.instantiate()
			
			# every unit_scene (instantiated or reused) is newly initialized
			# with the specifications from the battle object
			# this does not include positioning of the unit_scene
			unit_scene.initialize(squad_units[unit_id], _map_to_position(Vector2i(-5, -5)))
			squad_scene.add_unit(unit_scene)
		
		_add_squad(squad_scene)
	
	current_squad_label.text = str(BattleManager.battle.get_turn_squad_id())


func _add_squad(squad: SquadScene):
	squads[squad.squad_id] = squad
	squads_node.add_child(squad)


### HANDLERS FOR BATTLE SIGNALS ###
func _on_battle_started():
	for squad_id: int in squads:
		for unit_id: int in squads[squad_id].units:
			squads[squad_id].units[unit_id].move_to(_map_to_position(BattleManager.battle.squads[squad_id].units[unit_id].coords))

func _on_new_turn(squad_id: int):
	current_squad_label.text = str(squad_id)
	
	# highlight all units in current squad
	var coords: Array[Vector2i] = []
	for unit: Unit in BattleManager.battle.squads[squad_id].units.values():
		coords.append(unit.coords)
	map_node.set_highlights(coords)

func _on_effect_tree_applied(effect_tree: Effect):
	render_effect_tree(effect_tree)



func _map_to_position(coords: Vector2i) -> Vector2:
	return map_node.base_map_node.to_global(map_node.base_map_node.map_to_local(coords))




func render_effect_tree(effect: Effect):
	print("Rendering Effect!")
	match effect.effect_type:
		"spawn_unit":
			await _spawn_unit(effect)
	
	for child_effect in effect.child_effects:
		print("entering child")
		render_effect_tree(child_effect)


func _get_atlas_coords_from_cell(cell: Cell) -> Vector2i:
	return Vector2i(0,0) #TODO

func _spawn_unit(effect: Effect) -> Signal:
	var unit_scene: UnitScene = UNIT_SCENE.instantiate()
	unit_scene.initialize(effect.data.unit, map_node.base_map_node.map_to_local(Vector2i(3,3)))
	
	# add unit_scene to indices
	unit_nodes_by_id[effect.data.unit.unit_id] = unit_scene
	
	# connect to clicked signal of unit_scene
	unit_scene.clicked.connect(_on_unit_clicked)
	# add unit_scene to scene
	squads[effect.data.squad_id].add_unit(unit_scene)
	
	return get_tree().create_timer(effect.duration/10.0).timeout
	
func _on_unit_clicked(unit: UnitScene):
	active_unit = unit
	active_unit_panel.set_unit(unit)

func _on_ability_clicked(ability_type: Types.AbilityType):
	if DataCatalog.abilities[ability_type].is_instant:
		BattleManager.execute_command(Command.new("ability", Vector2i(0,0), {
			"ability_type": ability_type,
			"unit_id": active_unit.unit_id,
			"squad_id": active_unit.squad_id,
		} ))
	else:
		var allowed_coords: Array[Vector2i] = BattleManager.battle.get_ability_allowed_cells(active_unit.squad_id, active_unit.unit_id, ability_type)
		map_node.set_highlights(allowed_coords)

func _on_tile_highlight_clicked(coords: Vector2i):
	BattleManager.execute_command(Command.new("ability", Vector2i(0,0), {
			"ability_type": active_ability_type,
			"unit_id": active_unit.unit_id,
			"squad_id": active_unit.squad_id,
			"target_coords": coords
		} ))
		
	#TODO reset ui after click
	
func _on_start_battle_button_pressed() -> void:
	BattleManager.start_battle()

func _on_end_turn_button_pressed() -> void:
	BattleManager.end_turn()


func _on_spawn_unit_button_pressed() -> void:
	BattleManager.execute_command(Command.new("spawn_unit", Vector2i(0,0), {"unit_dict": Unit.new(-1, -1, Types.UnitType.WARRIOR, Vector2i(0,0))}))


func _on_create_battle_button_pressed() -> void:
	GameManager.create_battle()
