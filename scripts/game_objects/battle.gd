extends RefCounted
class_name Battle

var type: String # private / public / local
var online: bool
var mode_name: String
var admin_id: int
#var players: Dictionary[int, Player] # player_id : player_reference
var lobby_code: int
var squads: Dictionary[int, Squad] # squad_id(TODO where are squad ids decided? should be managed by battle) : squad reference
var map: Map

var next_squad_id = 0
var squad_order: Array[int]
var current_turn_index: int = -1

var units_by_coords: Dictionary[Vector2i, Unit] = {} # coords : unit reference


### Signals that the battle emits to notify the game when the state has changed ###
signal battle_started()
signal map_updated()
signal new_turn(squad_id: int)
signal effect_tree_applied(effect_tree: Effect)


func _init(_map: Map = Map.new(), _squads: Dictionary[int, Squad] = {}, _mode_name: String = "") -> void:
	map = _map
	squads = _squads
	mode_name = _mode_name
	squad_order = squads.keys()
	
	while next_squad_id in squads.keys():
		next_squad_id += 1

### UPDATE METHODS, usually called by BattleManager ###
func add_squad(squad: Squad):
	if not squad.squad_id in squads.keys():
		squads[squad.squad_id] = squad
	else:
		squad.squad_id = next_squad_id
		squads[next_squad_id] = squad
		while next_squad_id in squads.keys():
			next_squad_id += 1
	squad_order.append(squad.squad_id)

func start():
	current_turn_index = 0
	new_turn.emit(squad_order[current_turn_index])
	battle_started.emit()

func set_map(_map: Map):
	print("Map set!")
	map = _map
	map_updated.emit()

func execute_command(command: Command):
	var root_effect: Effect = Effect.new()
	root_effect.child_effects = _get_command_effects(command)
	
	_resolve_and_apply_effect_tree(root_effect)

	effect_tree_applied.emit(root_effect)
	
func end_turn():
	current_turn_index += 1
	current_turn_index %= squad_order.size()
	new_turn.emit(squad_order[current_turn_index])





### INTERNAL LOGIC METHODS ###
func _get_command_effects(command: Command):
	var effects: Array[Effect] = []
	match command.command_type:
		"spawn_unit":
			effects.append(Effect.new("spawn_unit", 1, command.target_coords, {"unit": Unit.from_dict(command.data.unit_dict)}))
		"ability":
			match command.data.ability_type:
				"move_along_axis":
					effects.append(Effect.new("move_along_axis", 1, command.target_coords, {"unit_id": command.data.unit_id, "target_coords": command.data.target_coords}))
	return effects

func _resolve_and_apply_effect_tree(effect_tree: Effect): # fills in the Effect-Tree IN PLACE
	# 1. Flatten the root effect tree into a time queue of effects
	var effect_time_queue: Dictionary[int, Array] = {}
	_time_queue_from_effect_tree(effect_tree, effect_time_queue, 1)
	
	# 2. while-loop through time queue, apply effects, add resulting child effects to time queue
	var current_time: int = 0
	var current_effect: Effect
	while !effect_time_queue.is_empty():
		print("ETQ while")
		# skip empty buckets
		print(effect_time_queue)
		print(effect_tree.to_dict())
		while !effect_time_queue.has(current_time):
			current_time += 1
		
		# get next timed effect
		current_effect = effect_time_queue[current_time].pop_back()

		# remove bucket if now empty
		if effect_time_queue[current_time].is_empty():
			effect_time_queue.erase(current_time)
		
		# apply effect, get child effects
		var child_effects: Array[Effect] = apply_effect(current_effect)

		# add child effects to effect tree (the effect itself) for the visualization
		current_effect.child_effects.append_array(child_effects)
		# add child effects to time queue (for further timed simulation)
		var child_time = current_time + current_effect.duration
		for child_effect in child_effects:
			add_effect_to_time_queue(effect_time_queue, child_time, child_effect)


func _time_queue_from_effect_tree(effect_tree: Effect, effect_time_queue: Dictionary[int, Array], current_time: int):
	add_effect_to_time_queue(effect_time_queue, current_time, effect_tree)
	
	for child_effect in effect_tree.child_effects:
		_time_queue_from_effect_tree(child_effect, effect_time_queue, current_time+effect_tree.duration)

func add_effect_to_time_queue(time_queue: Dictionary[int, Array], time: int, effect: Effect):
	if !time_queue.has(time):
		time_queue[time] = []
	time_queue[time].append(effect)
	
func apply_effect(effect: Effect) -> Array[Effect]:
	print("Applying Effect!")
	match effect.effect_type:
		"spawn_unit":
			# apply
			_spawn_unit(effect.data.unit, effect.data.squad_id)
			# compute children
			
			if not effect.data.unit.coords.y > 5:
				var extra_spawn: Effect = Effect.new("spawn_unit", 1, Vector2i(0,0), {"unit": Unit.new(-1, -1,Types.UnitType.WARRIOR, effect.data.unit.coords, 10)})
				extra_spawn.data.unit.coords += Vector2i(1, 1)
				# return child effects
				return [extra_spawn]
	return []
# TODO establish -1 as undefined id to be defined, maybe not necessary?



### EFFECT APPLIERS ###
func _spawn_unit(unit: Unit, squad_id: int):
	squads[squad_id].add_unit(unit)
	units_by_coords[unit.coords] = unit

func _move_unit(unit: Unit, new_coords: Vector2i) -> void:
	units_by_coords.erase(unit.coords)
	unit.coords = new_coords
	units_by_coords[new_coords] = unit




### INFORMAION RETRIEVAL for battle scene ###
func get_ability_allowed_cells(squad_id: int, unit_id: int, ability_type: Types.AbilityType) -> Array[Vector2i]:
	var unit: Unit = get_unit(squad_id, unit_id)
	var ability_data = DataCatalog.abilities[ability_type]
	var allowed_cells: Array[Vector2i]
	for step: Vector2i in ability_data.target_pattern.base_steps:
		for multiple in range(ability_data.target_pattern.multiples):
			allowed_cells.append(step)
			step = step + step # TODO: is this defined for vector2?
	
	# TODO: remove unreachable or already used cells
	return allowed_cells
	
func get_unit_abilities(squad_id: int, unit_id: int) -> Array[Ability]:
	var unit: Unit = get_unit(squad_id, unit_id)
	var abilities: Array[Ability] = []
	for ability_type in DataCatalog.units[unit.unit_type].abilities:
		abilities.append(Ability.new(ability_type, get_ability_allowed_cells(unit.squad_id, unit.unit_id, ability_type), true))
		
	return abilities

func get_turn_squad_id():
	return squad_order[current_turn_index]






func get_unit(squad_id: int, unit_id: int) -> Unit:
	return squads[squad_id].units[unit_id]

func to_dict() -> Dictionary[StringName, Variant]:
	var _squads = {}
	for key in squads.keys():
		_squads[key] = squads[key].to_dict()
		
	return {
		"mode_name": mode_name,
		"online": online,
		"type": type,
		"admin_id": admin_id,
		"squads": _squads,
		"lobby_code": lobby_code
	}

static func from_dict(data: Dictionary[StringName, Variant]) -> Battle:
	var battle = Battle.new()
	
	var _squads: Dictionary[int, Squad] = {}
	for key in data["squads"].keys():
		_squads[key] = Squad.from_dict(data["squads"][key])

	battle.mode_name = data.get("mode_name", "")
	battle.online = data.get("online", false)
	battle.type = data.get("type", "public")
	battle.admin_id = data.get("admin_id", -1)
	battle.squads = _squads
	battle.lobby_code = data.get("lobby_code", "")
	return battle
